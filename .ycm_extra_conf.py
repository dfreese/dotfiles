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

def IsHeaderFile(filename):
    extension = os.path.splitext(filename)[1]
    return extension in HEADER_EXTENSIONS

def GetCompilationInfoForFile(database, filename):
    if IsHeaderFile(filename):
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
    return database.GetCompilationInfoForFile(filename)

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

def MakeRelativePathsInFlagsAbsolute(flags, working_directory):
    if not working_directory:
        return list(flags)
    new_flags = []
    make_next_absolute = False
    path_flags = [ '-isystem', '-I', '-iquote', '--sysroot=' ]
    for flag in flags:
        new_flag = flag

        if make_next_absolute:
            make_next_absolute = False
            if not flag.startswith('/'):
                new_flag = os.path.join(working_directory, flag)

        for path_flag in path_flags:
            if flag == path_flag:
                make_next_absolute = True
                break

            if flag.startswith(path_flag):
                path = flag[ len(path_flag): ]
                new_flag = path_flag + os.path.join(working_directory, path)
                break

        if new_flag:
            new_flags.append(new_flag)
    return new_flags


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

def FlagsForCompilationDatabase(root, filename):
    try:
        # Last argument of next function is the name of the build folder for
        # out of source projects
        compilation_db_path = FindNearest(root, 'compile_commands.json', BUILD_DIRECTORY)
        compilation_db_dir = os.path.dirname(compilation_db_path)
        logging.info("Set compilation database directory to " + compilation_db_dir)
        compilation_db =  ycm_core.CompilationDatabase(compilation_db_dir)
        if not compilation_db:
            logging.info("Compilation database file found but unable to load")
            return None
        # return database.GetCompilationInfoForFile(filename)
        compilation_info = GetCompilationInfoForFile(compilation_db, filename)
        if not compilation_info:
            logging.info("No compilation info for " + filename + " in compilation database")
            return None
        return list(compilation_info)
        '''
        This seemed to be causing problems.  Figure out what was up as some point.
        return MakeRelativePathsInFlagsAbsolute(
                compilation_info.compiler_flags_,
                compilation_info.compiler_working_dir_)
        '''
    except:
        return None

def FlagsForFile(filename):
    root = os.path.realpath(filename);
    compilation_db_flags = FlagsForCompilationDatabase(root, filename)
    if compilation_db_flags:
        final_flags = compilation_db_flags
    else:
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
            'do_cache': True
            }
