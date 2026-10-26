# AGENTS.md

Anthonyize is a set of bash scripts that configure a machine to its owner's
habits: system-wide bash aliases, prompt and alias completion, global Git
config and aliases, SSH known hosts, an SSH key for signing Git commits, and
(on Windows) the ssh-agent service. Targets are GNU/Linux, macOS, Git
Bash/MSYS2 and Cygwin. There is no build step.

## Do not run it on the host

`./anthonyize` modifies the machine it runs on. It copies files into `/etc`,
appends to the system-wide bashrc, rewrites `~/.gitconfig`, appends to
`~/.gitexcludes` and `~/.ssh/known_hosts`, may generate an SSH key (with an
interactive passphrase prompt) and may change the login shell. Never run it
on the host unless the user explicitly asks. The same goes for
`scripts/cli-setup-bashrc` and `scripts/anthonyize-create-flag-file`, which
act as soon as they are sourced.

## Testing

Follow test-driven development for every bug fix and behavior change:

1. Add a test that checks the expected behavior.
2. Run it against the current code and confirm that it fails, and that it
   fails for the reason you expect. A test that passes before the change
   proves nothing.
3. Implement the change, rerunning the test until it passes. Then run the
   other tests to check that nothing else broke.

Put tests in `tests/` as bash scripts that exit non-zero on failure. Because
`./anthonyize` modifies the machine it runs on, run tests only inside a
throwaway container with the repo mounted read-only. Each test installs what
it needs (at least `git`):

```bash
docker run --rm -v "$PWD":/src:ro ubuntu:24.04 bash /src/tests/<test>
```

- When a test runs `./anthonyize`, redirect its stdin from `/dev/null` so
  that the `ssh-keygen` passphrase prompt doesn't wait for input.
- Where it matters, run `./anthonyize` twice so that the update path (flag
  file already present) is covered too.
- For busybox-based userland, use the `alpine` image, which needs
  `apk add bash git`.
- Docker can't run macOS or Windows. If a change only affects those
  platforms, say so, and explain how you checked it instead.
- Also run `bash -n <file>` on every script you edit. shellcheck isn't
  installed here, but use it if it's available.

## Layout

- `anthonyize`: the entry point. It sources each `scripts/<area>` file and
  calls that file's top-level function in this order: `tweakFilesystem`
  (`fs`), `installConfigFiles` (`conffiles`), `setupCli` (`cli`),
  `configureCommands` (`commands`), `setupServices` (`services`). Last, it
  writes the flag file `/etc/anthonyzation.d/anthonyzation-was-run`.
- `scripts/common`: sourced by every script. It holds the path variables
  (`SCRIPTS_DIR`, `CONFIG_DIR`, `ANTHONYZATION_FLAG`), the `message*`
  helpers, `checkParamNum`, `setSystemInfo` (sets `OS`, `DISTRO`, `VER`),
  `superUserDo` and `haveFlagFile`.
- `scripts/cli-setup-bashrc` and `scripts/anthonyize-create-flag-file`: run
  as root via `superUserDo bash -c "source ..."`, so they source `common`
  themselves.
- `scripts/services-setup-runas.ps1`: Windows only. It elevates itself to
  admin and enables ssh-agent.
- `config/etc/`: copied into `/etc`. The line appended to the bashrc sources
  `/etc/anthonyzation.d/bash_anthonyzation`, which loads the rest. That makes
  these files part of every interactive shell on the target machine.

## Rules that are easy to break

- **Portability.** Code has to work on Ubuntu, Alpine (busybox tools), macOS
  (BSD userland, and `/bin/bash` is 3.2, so no associative arrays and no
  `${var,,}`) and Git Bash (no `sudo`, no `chsh`, sometimes no `tabs`).
  - Stick to POSIX tools and flags: `grep -E` and `sed -E`, not `grep -P`.
    Avoid GNU-only options such as `realpath --relative-to`.
  - Before using a command or flag, check that it exists with `command -v`,
    or by trying it (see the `less -x` check in `scripts/commands`). If it's
    missing, print a `messageStatus` and skip the step instead of failing.
  - To branch per platform, test `$OS` in `scripts/*`: `GNU/Linux`,
    `Darwin`, or anything else, which means Windows. Installed files test
    `$BASH_ANTHONYZATION_OS` instead.
  - Run privileged commands through `superUserDo`, never bare `sudo`. It
    also handles `doas`, running as root, and Windows.
- **Re-runs.** Users re-run `./anthonyize` to pick up updates, so every step
  must be safe to repeat. Guard appends with `grep -qF`, as
  `add_ssh_fingerprint` does. Put one-time steps behind `haveFlagFile`, as
  `setupCli` does.
- **Errors.** Every top-level function is called as `foo || return`, which
  turns off `set -e` inside it. Chain each command that can fail with
  `|| return`, and report failures with `messageError`, which prints to
  stderr and returns false.
- **Files under `config/etc/`:**
  - They run at the start of every interactive shell, so keep them quiet and
    fast, and make sure they never exit or fail.
  - `installConfigFiles` rewrites each file in `config/etc/anthonyzation.d/`
    with `sed`, replacing placeholders such as
    `__COMPLETION_FUNCTION_BODY__`. Keep that directory flat, because the
    destination path is built with `basename`.
  - `bash.bash_aliases` has to stay POSIX `sh` compatible. Define each alias
    on its own line as `alias name=...`, because `alias_completion` greps for
    that pattern to set up completion.
  - `bash_anthonyzation` keeps its own copy of `setSystemInfo` (which sets
    `BASH_ANTHONYZATION_*`) because it runs without the repo present. Keep
    the copy in sync with `scripts/common`.
  - `bash_alias_completion` is GPL code vendored from
    `cykerway/complete-alias`. Keep local changes minimal.
- Files written onto the target machine start with the "CREATED BY
  ANTHONYZATION SCRIPT" or "ADDED BY ANTHONYZATION SCRIPT" banner and the
  repo URL.

## Style

- Bash scripts have no file extension and start with `#!/bin/bash -e`.
  Indent with 4 spaces, except in `bash.bash_aliases`, which uses tabs.
- Name functions in camelCase, declare function variables with `local`, and
  quote expansions as `"${var}"`.
- Document a function's arguments in an `# EXPECTED PARAMS:` comment and
  check them with `checkParamNum` (see `scripts/common`).
- Prefer `message` (section headings), `messageStatus` (info and skipped
  steps), `messageWarning` and `messageError` over bare `echo`.
- Comments on a workaround say which platform needs it and why, e.g. "the
  Alpine Linux busybox version of less doesn't [support -x]".

## Docs and commits

- `README.md` lists the customization points. Update it when you add or
  move one.
- Each commit makes one change. The subject is in the imperative mood with no
  type prefix, for example "Avoid using 'less -x' when unavailable". Follow
  the 50/72 rule.
- Commits are SSH-signed. Don't bypass signing.
