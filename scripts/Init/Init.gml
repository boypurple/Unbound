randomise()
DialogueDatabaseInit();                            // Build NPC database first
ChatterboxLoadFromFile("Dialogue/dialogue.yarn");  // Load dialogue file
DialogueEventsInit();                              // Register event commands