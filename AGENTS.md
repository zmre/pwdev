# AGENTS.md

Guidance for AI agents (and humans) working on this repo.

## What this repo is

A single `flake.nix` providing ready-made Nix dev shells for working in repos
that don't have their own flake. Usage from anywhere:
`nix develop github:zmre/pwdev#<shell>`. There is intentionally no build
output, no packages, no app — just `devShells`.

Available shells: `rust`, `ts` / `ts24`, `python` / `python312`, `go`, `all`.

## Layout

Everything lives in `flake.nix`:

- `inputs`: pinned to a stable nixpkgs release (`nixos-25.11`) so binary
  caches are hit — don't switch to unstable without a reason
- `nixConfig`: extra substituters (nix-community, zmre cachix)
- `common`: a shared list of general build tools (just, jq, make, cmake,
  pkg-config, hyperfine) appended to some shells
- One `devShells.<name> = pkgs.mkShell { ... }` block per language, plus
  short aliases (e.g. `devShells.ts = devShells.ts24`)
- `devShells.all`: concatenates the buildInputs and shellHooks of all the
  other shells

## Conventions for adding or changing a shell

1. Follow the existing pattern: a `mkShell` with `buildInputs`, and a
   `shellHook` that echoes which environment is active and sets `PS1` to
   include a `pwdev-<name>` tag.
2. Prefer batteries-included: these shells exist to make random cloned repos
   work, so include the tooling a typical project expects (compiler,
   formatter, linter, LSP, debugger).
3. Use packages from the pinned nixpkgs only; no fetchers with hardcoded
   hashes, no `npm install -g` / `pip install` / `cargo install` style global
   installs in shellHooks.
4. Add Darwin-only deps under `pkgs.lib.optionals pkgs.stdenv.isDarwin`.
5. If you add a new language shell, also:
   - add it to `devShells.all` (both `buildInputs` and `shellHook`)
   - add a short alias if the canonical name is versioned (e.g. `python` →
     `python312`)
   - update the shell list and "What's in each environment" section in
     `README.md` and the list above

## Testing changes

```bash
# fast sanity check that the flake evals (catches bad package names)
nix eval path:.#devShells.aarch64-darwin.<shell>.name --accept-flake-config

# actually build the shell and prove tools are on PATH
nix develop path:.#<shell> --accept-flake-config -c go version   # etc.

# check the combined shell still works after any change
nix eval path:.#devShells.aarch64-darwin.all.name --accept-flake-config
```

Use the `path:.` prefix so untracked files are included. Substitute your
system for `aarch64-darwin` if different. Don't run `nix flake update`
unless the task is specifically to bump inputs.

## Gotchas

- The python overlay disables `setproctitle` tests to work around a macOS
  fork-test segfault; leave it in place while nixpkgs 25.11 is pinned.
- The `go` shell sets `hardeningDisable = ["fortify"]` because fortify
  breaks delve debug builds; keep it if you touch that shell.
- `common` is appended inconsistently: python and go get it always, ts only
  on Darwin, rust not at all. Keep README claims about it accurate.
