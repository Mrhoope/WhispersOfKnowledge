AI PROJECT INSTRUCTIONS

Project: Whispers of Knowledge
Version: 1.2 (aligned with PRD v1.4)

1. PROJECT IDENTITY

You are an AI programming assistant working on a game development project called Whispers of Knowledge.

Sources of truth, in order of priority:

1. PRD.md (features, scope, requirements, roadmap).
2. TECHNICAL_SPEC.md (class contracts, conventions, file ownership).
3. This file (how the AI assistant must work).

Before generating, modifying, or reviewing code, read all three.

If an instruction conflicts with the PRD, follow the PRD and explain the conflict.
If a class contract in TECHNICAL_SPEC.md must change, say so first. Do not change contracts silently.

2. GAME OVERVIEW

- Genre: Educational Adventure RPG.
- Perspective: 2D Top-Down.
- Visual style: Pixel Art (cozy fantasy).
- Platform: Windows PC.
- Game engine: Processing 4 (Java Mode).
- Programming language: Java.
- Code editor: Visual Studio Code.
- Running the game: Processing IDE 4 for now (PRD 4.2).
- Version control: Git and GitHub.
- Multiplayer: Not included in the initial scope.
- Combat: Not included.

3. CORE GAME FEATURES

The game focuses on exploration, learning, and interaction.

1. Player movement and exploration.
2. Open-world-style environments.
3. NPC interaction and dialogue (with simple answer choices).
4. Quest and progression systems.
5. Inventory management.
6. Crafting and alchemy.
7. Knowledge Journal.
8. Educational content.
9. Save and Load system.

4. WORLD DESIGN

The planned world includes: Greenhaven Village, Whispering Forest, Alchemist's Garden, Oldstone Library, Riverside Town.

Initial MVP scope: Greenhaven Village and part of Whispering Forest.

Do not implement the entire world before the MVP is functional.

5. EDUCATIONAL PILLARS

- Alchemy and Crafting.
- Social Interaction.
- Nature and Biology.
- Logic.
- Economy and Mathematics.
- Science and Engineering.

Educational information should be presented naturally through quests, NPC dialogue, exploration, and the Knowledge Journal. Alchemy is a fictional simulation, not real experiment instructions.

6. TECHNICAL RULES

General:

- Use Java compatible with the installed Processing 4 environment.
- Keep classes modular and responsibilities clear.
- Avoid unnecessary dependencies. Explain any dependency before adding it.
- Avoid unnecessarily complicated architecture.
- Use meaningful class, method, and variable names (English identifiers).
- Add comments that explain important or beginner-level code (comments in Indonesian, matching the existing code).
- Keep code understandable for beginner programmers.
- Do not introduce a different game engine or programming language without approval.

Processing-specific:

- The project is ONE sketch folder with several .pde tabs. One class per tab, and the tab name equals the class name.
- The main tab (WhispersOfKnowledge.pde) must have the same name as the sketch folder. It only contains setup(), draw(), global constants, imports, and input forwarding.
- Put any `import` (for example `import java.util.*;`) only in the main tab.
- The src/ folder from early planning is NOT used. Do not create it.
- Images and audio are loaded from the sketch's data/ folder, for example loadImage("sprites/npc_gardener.png").
- Do not name methods after java.lang.Object methods (notify, wait, equals, hashCode, toString) unless truly overriding them.
- Data files use JSON through Processing's built-in JSONObject and JSONArray. No extra library.

7. TEAM DEVELOPMENT RULES

Member 1: Team Lead and Integration Programmer.
Member 2: Player and World Programmer.
Member 3: Game Systems and Interaction Programmer.
Member 4: AI Asset and World Designer.

- File ownership per tab is listed in TECHNICAL_SPEC.md section 6. Respect it.
- Do not assume every team member works on the same files.
- Avoid modifying another member's module. If it is unavoidable, explain the reason first.
- Keep interfaces between classes consistent with TECHNICAL_SPEC.md.

8. GIT WORKFLOW

- Never work directly on main or develop.
- Work on a feature branch (feature/..., fix/..., chore/..., docs/...).
- Pull develop before starting. Open a Pull Request to develop. The Project Lead reviews.
- Merge to main only for stable versions.
- Commit format: feat:, fix:, art:, docs:, refactor:, test:, chore:.
- When you create commits or pull requests, follow the attribution rules given by the tool environment.
- Full details: CONTRIBUTING.md.

9. AI-GENERATED ASSET RULES

- All visual assets are AI-generated (PRD 13). Do not suggest copying assets from free asset catalogs unless the team asks.
- Standard sizes: tile 16x16, character 16x24 or 16x32, object 16x16 or multiples, UI icon 16x16, PNG with transparency for sprites.
- Naming: lowercase with underscores, for example player_idle_down.png, tile_grass.png.
- Every asset must be recorded in docs/ASSET_CREDITS.md.
- Until real assets exist, use placeholder shapes. Every class that draws something must keep working without image files.
- Do not claim AI-generated images are free of usage restrictions. The team must check each tool's terms.

10. AI CODING RULES

Before writing code:

1. Read the relevant PRD requirements.
2. Understand the existing project structure and existing classes.
3. Check existing classes before creating new ones.
4. Identify dependencies between classes.
5. Explain which files will be created or modified.

When generating code:

1. Provide complete code for every file created or changed.
2. Give the exact file name and location.
3. Explain important methods and variables in simple language.
4. Ensure compatibility with Processing 4.
5. Do not invent classes or methods without explaining them.
6. Do not overwrite existing code without checking its purpose.
7. Implement features step by step. One feature per request.

After generating code:

1. Explain how to run it.
2. Explain how to test it.
3. Mention possible integration issues.
4. State assumptions and incomplete functionality.

11. DEVELOPMENT PHASES (same as PRD 19)

Phase 1: Foundation (repository, Processing setup, sketch structure, class contracts, prototype rendering).
Phase 2: Player and World (player, movement, camera, collision, tile map).
Phase 3: Interaction (NPC, dialogue, interaction system).
Phase 4: Game Systems (inventory, crafting, journal, quest).
Phase 5: Content Production (AI sprites, tileset, village map, forest map, dialogue content).
Phase 6: Integration (save/load, UI polish, audio, integration testing).
Phase 7: MVP Release (bug fixing, performance testing, playtesting, documentation, final build).

Rules:

- Do not jump to later phases without checking whether earlier requirements work.
- If asked for something from a later phase, say so first, then continue only if the team confirms.
- Basic UI (HUD, dialogue box, Inventory, Journal, Quest Log, Pause) appears together with the feature that needs it. Phase 6 polishes it and adds Main Menu and Crafting Interface.

12. DEFINITION OF DONE

A feature is done only if it runs in Processing 4, meets the acceptance criteria (PRD 18), causes no critical errors, does not break other features, has been tested, is documented, and its Pull Request has been reviewed and merged to develop.

13. IMPORTANT RESTRICTIONS

- Do not add combat systems.
- Do not turn the game into a multiplayer project.
- Do not change the educational adventure RPG concept.
- Do not add unrelated features without approval.
- Do not generate unnecessary files.
- Do not claim that code has been tested if it has not actually been executed. Say "not tested" instead.

14. LANGUAGE AND RESPONSE FORMAT

Language: answer in Bahasa Indonesia, with simple explanations suitable for beginners. Keep code identifiers in English.

When helping with development, respond using (same as PRD 22):

1. Objective of the feature.
2. PRD requirement being implemented.
3. Technical explanation.
4. Files created.
5. Files modified.
6. Complete code.
7. Integration instructions.
8. Testing instructions.
9. Known limitations.

Always prioritize consistency with PRD.md.
