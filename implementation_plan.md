# Goal Description

Automate the process of animating the GLSL shaders by leveraging an LLM API (OpenAI Codex/GPT). Instead of applying generic regex-based animations (like in `animate_all_aggressively.py`) or manually verifying and animating each of the 100+ shaders (as tracked in `task.md`), we will build a Python script to send each shader to the OpenAI API. The LLM will be instructed to intelligently rewrite the GLSL code to include bespoke, beautiful pattern animations using `iTime` while preserving the original mood, structure, and dominant colors.

## User Review Required

> [!WARNING]
> This approach requires making API calls to OpenAI, which will incur usage costs. Please ensure you are comfortable with this before we proceed. We should test on a small batch first to review the quality before processing all ~150 files.

## Open Questions

> [!IMPORTANT]
> 1. **Model Choice:** "Codex" is officially deprecated, so I recommend using `gpt-4o` (or `gpt-4-turbo`) for the best coding capabilities. Does that work for you?
> 2. **API Key:** Do you already have an `OPENAI_API_KEY` set as an environment variable on your system? (If not, we'll need to install the `openai` python package and you will need to provide a key).
> 3. **Output Location:** Do you want the script to overwrite the existing `.glsl` files directly, or output them to a separate folder (e.g., `animated_glsl/`) first so you can review them safely?

## Proposed Changes

### Automation Script

#### [NEW] [process_shaders_with_llm.py](file:///d:/GLSL%20bds/process_shaders_with_llm.py)
Create a new Python script that will:
1. Iterate over all `.glsl` files in the workspace.
2. Skip files that have already been processed (using a tracking file like `processed_shaders.json`).
3. Read the existing GLSL code.
4. Construct a prompt instructing the LLM to:
   - Act as an expert shader developer.
   - Analyze the current static shader and its dominant colors/patterns.
   - Rewrite the `void main()` function to include high-quality, bespoke animations using the `iTime` uniform.
   - Output *only* valid WebGL fragment shader code.
5. Send the prompt using the `openai` Python library.
6. Parse the response to extract the GLSL code block.
7. Overwrite the `.glsl` file (or write to a new folder based on your preference).
8. Automatically regenerate the corresponding HTML preview files so they can be viewed immediately.

## Verification Plan

### Automated Tests
- Run the script on a small batch (e.g., `python process_shaders_with_llm.py --limit 3`) to verify that the API calls succeed, the outputs are valid GLSL, and the HTML files are generated without errors.

### Manual Verification
- Open the newly generated HTML files in a browser to visually confirm that the shaders compile successfully, retain their original aesthetics, and feature bespoke animations.
