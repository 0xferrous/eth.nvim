# Repository Guidelines

## Project Structure & Module Organization
- `lua/eth-nvim/`: Core Lua modules (`init.lua`, `config.lua`, `utils.lua`, `explorers.lua`, `trace.lua`).
- `plugin/eth-nvim.lua`: Auto-loaded user commands and entrypoints.
- `spec/`: Busted tests (`*_spec.lua`) and helpers.
- `README.md`: User-facing docs; update when adding commands/APIs.
- `flake.nix`, `flake.lock`: Nix development/build environment.

## Build, Test, and Development Commands
- Enter dev shell: `nix develop`
- Run tests: `nix develop --command busted` (or `busted` if installed)
- Lint: `nix develop --command luacheck lua/`
- Format: `nix develop --command stylua .`
- Build (sanity): `nix build`

## Coding Style & Naming Conventions
- Language: Lua, 2-space indentation, no tabs.
- Formatting: `stylua` (config in `stylua.toml`).
- Linting: `luacheck` (config in `.luacheckrc`). Fix or justify warnings.
- Naming: modules `eth-nvim.*`; local identifiers `snake_case`; exported APIs in `init.lua` use concise verbs (e.g., `enable_trace_folds`).
- Keep functions small and pure where possible; avoid side effects in tests.

## Testing Guidelines
- Framework: Busted.
- Location: `spec/*_spec.lua`. Name new specs after the module (`trace_spec.lua`).
- Coverage: Add tests for new behavior and edge cases. Prefer pure helpers (e.g., expose minimal wrappers like `depth_for_line`) to avoid Neovim state in tests.
- Run: `busted` from the repo root or via Nix.

## Commit & Pull Request Guidelines
- Commits: Imperative subject, short (<72 chars), with context in the body. Group related changes; keep diffs focused.
- Message examples:
  - `feat(trace): add foldexpr with ANSI-safe parsing`
  - `test(utils): cover address normalization edge cases`
- PRs: Describe the change, rationale, and testing. Link issues. Include screenshots/asciicasts for UX changes (e.g., commands, folding). Ensure tests, lint, and format pass.

## Agent-Specific Instructions
- Place new user commands under `plugin/eth-nvim.lua`; core logic under `lua/eth-nvim/`.
- Do not introduce external runtime dependencies without discussion.
- Update `README.md` when adding or changing commands, config, or behavior.
- Prefer minimal, surgical changes; avoid refactors unrelated to the task.
