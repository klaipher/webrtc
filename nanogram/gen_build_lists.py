#!/usr/bin/env python3
"""Per-platform compile lists for this repository (pure Python, no build tools).

  gen_build_lists.py mac                      parse CMakeLists.txt + cmake/*.cmake of this repository
  gen_build_lists.py android <voip/CMakeLists.txt>   active (uncommented) voip/webrtc/... entries of the app
  gen_build_lists.py ios <third-party/webrtc/BUILD>  path literals of the iOS Bazel BUILD

Each prints one repository-relative path per line (sources only: .c .cc .cpp .mm .m .S .inc, plus .h/.hpp
when --headers is given). Paths that are not tracked in this repository (submodules, external libraries,
generated files) are printed to stderr as 'external: <path>'.
Lists are the files a platform names; conditionals (select(), if/else, remove_target_sources) are not
evaluated, so treat them as the superset the platform can compile.
"""
import glob, json, os, re, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC_EXT = re.compile(r'\.(c|cc|cpp|mm|m|S|inc)$')
ANY_EXT = re.compile(r'\.(c|cc|cpp|mm|m|S|inc|h|hpp)$')


def tracked():
    out = subprocess.check_output(['git', '-C', ROOT, 'ls-files'], text=True)
    return set(out.split('\n'))


def cmake_blocks():
    files = [os.path.join(ROOT, 'CMakeLists.txt')] + sorted(glob.glob(os.path.join(ROOT, 'cmake', '*.cmake')))
    bases = {'${webrtc_loc}': '', '${libsdkmacos_loc}': 'sdk/objc', '${libpffft_loc}': 'third_party/pffft/src',
             '${librnnoise_loc}': 'third_party/rnnoise/src', '${libsrtp_loc}': 'third_party/libsrtp',
             '${libcrc32c_loc}': 'third_party/crc32c/src', '${third_party_loc}': 'third_party'}
    out = []
    for f in files:
        s = open(f).read()
        for m in re.finditer(r'nice_target_sources\(\s*(\S+)\s+(\S+)\s*(.*?)\n\)', s, re.S):
            loc, body = m.group(2), m.group(3)
            if loc not in bases:
                continue  # libyuv (external) and libabsl (abseil's own CMake)
            for line in body.split('\n'):
                l = line.split('#')[0].strip()
                for tok in l.split():
                    if ANY_EXT.search(tok):
                        out.append((bases[loc] + '/' + tok).lstrip('/'))
    return out


def android_entries(path):
    out = []
    for line in open(path):
        l = line.split('#')[0].strip()
        for tok in l.split():
            for pre in ('voip/webrtc/', 'voip/third_party/'):
                if tok.startswith(pre) and ANY_EXT.search(tok):
                    rel = tok[len(pre):]
                    out.append(rel if pre == 'voip/webrtc/' else 'third_party/' + rel)
    return out


def ios_entries(path):
    out = []
    text = open(path).read()
    # ["webrtc/some/dir/" + path for path in [ "a.cc", "b.cc" ]]
    comp = re.compile(r'\[\s*"([^"]+)"\s*\+\s*path\s*for\s*path\s*in\s*\[(.*?)\]\s*\]', re.S)
    for m in comp.finditer(text):
        prefix = m.group(1)
        for lit in re.findall(r'"([A-Za-z0-9_./+-]+)"', m.group(2)):
            p = prefix + lit
            out.append(p[len('webrtc/'):] if p.startswith('webrtc/') else p)
    text = comp.sub('', text)
    for m in re.finditer(r'"([A-Za-z0-9_./+-]+\.(?:c|cc|cpp|mm|m|S|inc|h|hpp))"', text):
        p = m.group(1)
        out.append(p[len('webrtc/'):] if p.startswith('webrtc/') else p)
    return out


def main():
    mode = sys.argv[1]
    headers = '--headers' in sys.argv
    if mode == 'mac':
        raw = cmake_blocks()
    elif mode == 'android':
        raw = android_entries(sys.argv[2])
    elif mode == 'ios':
        raw = ios_entries(sys.argv[2])
    else:
        sys.exit(__doc__)
    t = tracked()
    keep = set()
    for p in raw:
        if not headers and not SRC_EXT.search(p):
            continue
        if p in t:
            keep.add(p)
        elif mode == 'ios' and 'sdk/' + p in t:
            keep.add('sdk/' + p)
        else:
            print('external: ' + p, file=sys.stderr)
    print('\n'.join(sorted(keep)))


if __name__ == '__main__':
    main()
