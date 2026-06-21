# Manual Procedural Shader Generation Plan

The goal is to manually recreate photographs of real-world objects (like the colored metal rings and bicycle rim structures) into procedural GLSL shaders, keeping their original structures, colors, and adding trippy animations. Finally, these shaders and their reference photos will be previewed in `moodboard_htmls/index.html`.

## User Review Required

> [!CAUTION]
> **Massive Scope Warning**
> Writing a custom, procedural GLSL shader that mimics a real-life object from scratch is a highly complex task that typically takes a technical artist hours per shader. Manually creating 49+ distinct procedural shaders in a single pass is not feasible. 
>
> **Proposed Iterative Approach**: I strongly recommend we tackle this iteratively. I will start by manually creating the procedural shaders for the **4 photos** located in the root `Trippy Ornaments` folder (`IMG_9786.JPG`, `IMG_9787.JPG`, `IMG_9868.JPG`, `IMG_9869.JPG`). Once we have perfected these 4 and confirmed the artistic direction, we can discuss the best approach for the remaining 49 photos in the `Trippy Ornaments-3-001` folder.

## Open Questions

> [!IMPORTANT]
> 1. Do you approve of starting with a smaller batch of the first 4 photos in `Trippy Ornaments` before tackling the 49 photos in `Trippy Ornaments-3-001`?
> 2. For the shaders, do you want full 3D procedural rendering using raymarching/SDFs to simulate the 3D depth of the metal rings, or 2D procedural patterns that mimic the layout and colors of the objects? (Raymarching is more realistic but much more complex).

## Proposed Changes

### 1. Manual Shader Creation for Batch 1
I will manually analyze the structures, colors, and details of the 4 photos in `Trippy Ornaments`:
- `IMG_9786.JPG` / `IMG_9787.JPG`: Colored metal rings (yellow, green, blue, red) attached to a blue frame.
- `IMG_9868.JPG` / `IMG_9869.JPG`: Structures made of welded bicycle rims.

I will create 4 new HTML files in `moodboard_htmls/trippy_ornaments_manual/`:
#### [NEW] [IMG_9786_manual.html](file:///d:/GLSL%20bds/moodboard_htmls/trippy_ornaments_manual/IMG_9786_manual.html)
#### [NEW] [IMG_9787_manual.html](file:///d:/GLSL%20bds/moodboard_htmls/trippy_ornaments_manual/IMG_9787_manual.html)
#### [NEW] [IMG_9868_manual.html](file:///d:/GLSL%20bds/moodboard_htmls/trippy_ornaments_manual/IMG_9868_manual.html)
#### [NEW] [IMG_9869_manual.html](file:///d:/GLSL%20bds/moodboard_htmls/trippy_ornaments_manual/IMG_9869_manual.html)

*These will contain the procedural GLSL code with animations (e.g., rotating rings, shifting colors, undulating structures).*

### 2. Update Preview Dashboard
#### [MODIFY] [index.html](file:///d:/GLSL%20bds/moodboard_htmls/index.html)
I will update the dashboard to include a new section to preview these manually created procedural shaders side-by-side with their original reference photos.

## Verification Plan

### Manual Verification
- Open `moodboard_htmls/index.html` in a web browser.
- Verify that the 4 manual procedural shaders are visible and animated.
- Compare the shaders to the original photos to ensure the structures and colors are recognizable.
