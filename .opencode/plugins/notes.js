/**
 * notes plugin for OpenCode.ai
 *
 * Auto-registers the skills directory via the config hook (no symlinks needed).
 *
 * Like the sibling harness plugin, this one injects no per-session bootstrap
 * context. The notes skills are task-triggered — you reach for one when a piece
 * of work is finished and needs writing up — so OpenCode's native `skill` tool
 * discovering them is all that is needed.
 */

import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export const NotesPlugin = async () => {
  const notesSkillsDir = path.resolve(__dirname, '../../skills');

  return {
    // Inject skills path into live config so OpenCode discovers notes skills
    // without requiring manual symlinks or config file edits.
    // This works because Config.get() returns a cached singleton — modifications
    // here are visible when skills are lazily discovered later.
    config: async (config) => {
      config.skills = config.skills || {};
      config.skills.paths = config.skills.paths || [];
      if (!config.skills.paths.includes(notesSkillsDir)) {
        config.skills.paths.push(notesSkillsDir);
      }
    },
  };
};
