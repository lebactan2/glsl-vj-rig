# Scaled Manual Shader Generation Plan

We have successfully validated the 2D procedural shader approach with backgrounds on the first 4 images. We now have 45 remaining images in the `trippyBasenames` list to convert. 

To speed up this massive undertaking, we will split the workload between two AI agents running in parallel.

## Workload Division

The remaining 45 images have been split into two batches.

### Batch 1 (My Task - 23 Images)
`IMG_0187`, `IMG_0188`, `IMG_4841`, `IMG_5132`, `IMG_5146`, `IMG_5373`, `IMG_5527`, `IMG_5577`, `IMG_5614`, `IMG_5620`, `IMG_5636`, `IMG_5662`, `IMG_5689`, `IMG_5693`, `IMG_5700`, `IMG_5702`, `IMG_5715`, `IMG_5761`, `IMG_5762`, `IMG_6006`, `IMG_6007`, `IMG_6291`, `IMG_6348`

### Batch 2 (Secondary Agent's Task - 22 Images)
`IMG_6349`, `IMG_6350`, `IMG_6385`, `IMG_6442`, `IMG_6444`, `IMG_6469`, `IMG_6494`, `IMG_6495`, `IMG_6496`, `IMG_6516`, `IMG_6527`, `IMG_6529`, `IMG_6581`, `IMG_8926`, `IMG_8953`, `IMG_9015`, `IMG_9017`, `IMG_9031`, `IMG_9072`, `IMG_9074`, `IMG_9077`, `IMG_9078`

## Instructions for the Secondary Agent

> [!IMPORTANT]
> Please copy the text block below and send it to the other agent in a new window to kick off their work on Batch 2!

```text
Please help me manually convert a batch of 22 photos into 2D procedural GLSL shaders. 

The images are located in the "Trippy Ornaments-3-001" folder (or similar if they were moved). The images are:
IMG_6349, IMG_6350, IMG_6385, IMG_6442, IMG_6444, IMG_6469, IMG_6494, IMG_6495, IMG_6496, IMG_6516, IMG_6527, IMG_6529, IMG_6581, IMG_8926, IMG_8953, IMG_9015, IMG_9017, IMG_9031, IMG_9072, IMG_9074, IMG_9077, IMG_9078

For each image:
1. Look at the original photograph to understand its structure, subject, colors, and background environment.
2. Create a new HTML file in `d:\GLSL bds\moodboard_htmls\trippy_ornaments_manual\` named `{IMG_NAME}_manual.html`.
3. Write a procedural 2D GLSL shader that mimics the layout, subjects, and colors of the original photo. Include a procedurally generated background that matches the photo's environment.
4. Add trippy, dynamic animations to the shader (e.g., color shifting, undulating shapes, glowing effects).
5. Update `d:\GLSL bds\moodboard_htmls\index.html`: Remove the image from the `trippyBasenames` array and add it to the `manualBasenames` array so it shows up correctly in the dashboard preview.

Another agent is working on Batch 1 in parallel, so please only process the 22 images listed above. You can look at `IMG_9786_manual.html` as a reference for the expected style and code structure.
```

## My Next Steps (Batch 1)

Once you approve this plan, I will immediately begin analyzing and writing the shaders for the 23 images in **Batch 1**, saving them to `moodboard_htmls/trippy_ornaments_manual/` and updating the `index.html` dashboard as I complete them. 

> [!TIP]
> Are you ready for me to start processing Batch 1?
