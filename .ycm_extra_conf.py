import platform
import os
import os.path
import fnmatch
import logging
import subprocess
import ycm_core
import re

'''
taken from https://jonasdevlieghere.com/a-better-youcompleteme-config/ which
sets up ycm to look for compile_commands.json in build directories outside of
where the files are specifically.

This might have more information on how to handle macOS specifc system
includes that are currently hacked into FlagsForSystem().

http://bastian.rieck.ru/blog/posts/2015/ycm_cmake/
'''


BASE_FLAGS = [
        '-Wall',
        '-Wextra',
        '-Wno-long-long',
        '-Wno-variadic-macros',
        '-fexceptions',
        '-ferror-limit=10000',
        '-DNDEBUG',
        '-std=c++1y',
        '-xc++',
        '-I/usr/lib/',
        '-I/usr/include/'
        ]

SOURCE_EXTENSIONS = [
        '.cpp',
        '.cxx',
        '.cc',
        '.c',
        '.m',
        '.mm'
        ]

SOURCE_DIRECTORIES = [
        'src',
        'lib'
        ]

HEADER_EXTENSIONS = [
        '.h',
        '.hxx',
        '.hpp',
        '.hh'
        ]

HEADER_DIRECTORIES = [
        'include'
        ]

BUILD_DIRECTORY = 'build';

class Git(object):
    def __init__(self):
        try:
            self.root = subprocess.check_output(
                    'git rev-parse --show-toplevel'.split()).splitlines()[0]
            self.files = subprocess.check_output(
                    'git ls-tree --full-tree --name-only -r HEAD'.split()
                    ).splitlines()
            self.root = self.root.decode('utf-8')
            self.files = tuple(x.decode('utf-8') for x in self.files)
        except:
            self.root = None
            self.files = None
        self._abs = None
        self._rel = None

    def abs_files(self):
        if not self.root:
            return None
        if not self._abs:
           self._abs = tuple(os.path.join(self.root, x) for x in self.files)
        return self._abs

    def relate(self):
        if not self.root:
            return None
        if not self._rel:
            self._rel = {os.path.basename(x):x for x in self.abs_files()}
        return self._rel


def IsHeaderFile(filename):
    extension = os.path.splitext(filename)[1]
    return extension in HEADER_EXTENSIONS

git = None

def AlternativeTransUnit(filename):
    global git
    if not git:
        git = Git()
    if not git.root:
        return None
    base, ext = os.path.splitext(os.path.basename(filename))

    # Try and replace the extension of the file first and see if there's
    # another file in the git directory
    for alt_ext in SOURCE_EXTENSIONS:
        alt_file = base + alt_ext
        if alt_file in git.relate():
            return git.relate()[alt_file]

    # Otherwise, just return the first translation unit, and hope for the best
    for alt_file in git.abs_files():
        root, ext = os.path.splitext(alt_file)
        if ext in SOURCE_EXTENSIONS:
            return alt_file
    # But if nothing really exists, then just don't worry about it
    return None

def GetCompilationInfoForFile(database, filename):
    if not IsHeaderFile(filename):
        return database.GetCompilationInfoForFile(filename)
    else:
        logging.info('trying to find alternative for header file')
        alt = AlternativeTransUnit(filename)
        if alt:
            logging.info('found alternative {}'.format(alt))
            return database.GetCompilationInfoForFile(alt)

    # Try old logic
    basename = os.path.splitext(filename)[0]
    for extension in SOURCE_EXTENSIONS:
        # Get info from the source files by replacing the extension.
        replacement_file = basename + extension
        if os.path.exists(replacement_file):
            compilation_info = database.GetCompilationInfoForFile(replacement_file)
            if compilation_info.compiler_flags_:
                return compilation_info
        # If that wasn't successful, try replacing possible header directory with possible source directories.
        for header_dir in HEADER_DIRECTORIES:
            for source_dir in SOURCE_DIRECTORIES:
                src_file = replacement_file.replace(header_dir, source_dir)
                if os.path.exists(src_file):
                    compilation_info = database.GetCompilationInfoForFile(src_file)
                    if compilation_info.compiler_flags_:
                        return compilation_info
    return None

def FindNearest(path, target, build_folder=None):
    candidate = os.path.join(path, target)
    if(os.path.isfile(candidate) or os.path.isdir(candidate)):
        logging.info("Found nearest " + target + " at " + candidate)
        return candidate;

    parent = os.path.dirname(os.path.abspath(path));
    if(parent == path):
        raise RuntimeError("Could not find " + target);

    if(build_folder):
        candidate = os.path.join(parent, build_folder, target)
        if(os.path.isfile(candidate) or os.path.isdir(candidate)):
            logging.info("Found nearest " + target + " in build folder at " + candidate)
            return candidate;

    return FindNearest(parent, target, build_folder)

def FlagsForClangComplete(root):
    try:
        clang_complete_path = FindNearest(root, '.clang_complete')
        clang_complete_flags = open(clang_complete_path, 'r').read().splitlines()
        return clang_complete_flags
    except:
        return None

def FlagsForInclude(root):
    try:
        include_path = FindNearest(root, 'include')
        flags = ["-I" + include_path]
        """
        for dirroot, dirnames, filenames in os.walk(include_path):
            for dir_path in dirnames:
                real_path = os.path.join(dirroot, dir_path)
                flags = flags + ["-I" + real_path]
        """
        return flags
    except:
        return None

'''
Used as a cache for the xcode path, so this isn't run everytime a file is opened
'''
xcode_base = None
xcode_flags = None

def FlagsForSystem():
    '''
    works for now, is probably a paraphrase of this answer, which is
    ```
    cpp -xc++ -v < /dev/null
    ```
    https://stackoverflow.com/a/27838745/2465202
    https://stackoverflow.com/a/11946295/2465202
    '''
    global xcode_base
    global xcode_flags
    if platform.system() == 'Darwin':
        if xcode_base is None:
            xcode_base = subprocess.check_output("xcode-select -p".split()).splitlines()[0]
            xcode_flags = [
                '-I/usr/local/include',
                '-I{0}'.format(os.path.join(xcode_base, 'Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1')),
                '-I{0}'.format(os.path.join(xcode_base, 'Toolchains/XcodeDefault.xctoolchain/usr/include/clang/9.0.0/include')),
                '-I{0}'.format(os.path.join(xcode_base, 'Toolchains/XcodeDefault.xctoolchain/usr/include')),
                '-I{0}'.format(os.path.join(xcode_base, 'Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk/usr/include')),
                ]
        return xcode_flags
    elif platform.system() == 'Linux':
        return []
    else:
        return []

def FindDatabase(root):
    try:
        compilation_db_path = FindNearest(root, 'compile_commands.json', BUILD_DIRECTORY)
        compilation_database_folder = os.path.dirname(compilation_db_path)
        logging.info("Set compilation database directory to " + compilation_database_folder)
        return ycm_core.CompilationDatabase(compilation_database_folder)
    except Exception as e:
        logging.info(e)
        return None

def FlagsForFile(filename):
    root = os.path.realpath(filename);
    database = FindDatabase(root)
    compilation_info = GetCompilationInfoForFile(database, filename)
    if compilation_info is not None:
        final_flags = list(compilation_info.compiler_flags_)
        rel_dir = compilation_info.compiler_working_dir_
    else:
        logging.info("No compilation info for " + filename + " in compilation database")
        rel_dir = ''
        final_flags = BASE_FLAGS
        clang_flags = FlagsForClangComplete(root)
        if clang_flags:
            final_flags = final_flags + clang_flags
        include_flags = FlagsForInclude(root)
        if include_flags:
            final_flags = final_flags + include_flags
    # Currently mac only
    final_flags += FlagsForSystem()
    return {
            'flags': final_flags,
            'do_cache': True,
            'include_paths_relative_to_dir': rel_dir,
            }
