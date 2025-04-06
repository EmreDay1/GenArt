# Persian Rug Generator

This Processing sketch generates colorful, recursive geometric patterns inspired by Persian rugs. The program creates intricate designs by recursively dividing the canvas and assigning colors based on neighboring sections.

## How It Works

The program creates symmetric patterns by dividing the canvas into increasingly smaller rectangles and coloring the dividing lines. The coloring follows specific rules that create harmony across the entire design.

### Key Components

1. **Grid System**: The canvas is divided into a grid of 2^n + 1 size (e.g., 257×257, 513×513, or 1025×1025).

2. **Color Palettes**: Nine pre-defined color palettes are included, each with 12 colors.

3. **Recursive Pattern**: The algorithm recursively divides rectangles, colors the dividing lines, and continues until it reaches a minimum rectangle size.

4. **Color Selection**: Colors for dividing lines are chosen based on the colors of the rectangle's corners plus a random shift value.

## Algorithm Explanation

The pattern generation uses a recursive subdivision algorithm inspired by traditional textile patterns:

### Initialization
1. The algorithm starts with a blank canvas and draws a border with the first color in the palette.
2. A random "shift" value is chosen to introduce variability in color selection.

### Recursive Division Process
1. For each rectangle in the grid:
   - Find the midpoint of each side
   - Connect these midpoints with horizontal and vertical lines
   - This divides the original rectangle into 4 smaller rectangles

2. Color selection for dividing lines follows this formula:
   ```
   newColorIndex = (topLeft + topRight + bottomLeft + bottomRight + shift) % paletteSize
   ```
   - This uses the colors from the four corners of the current rectangle
   - The shift value introduces controlled randomness
   - The modulo operation keeps colors within palette range

3. After drawing and coloring the dividing lines, the algorithm recursively applies the same process to each of the four new rectangles.

4. The recursion stops when rectangles become too small (when left and right positions are adjacent).

### Mathematical Properties

This algorithm creates a deterministic yet complex pattern because:

1. **Self-similarity**: Each quadrant contains a smaller version of the same pattern structure
2. **Color harmony**: Adjacent sections share corner colors, creating smooth transitions
3. **Controlled randomness**: The shift value changes the pattern without destroying its structure
4. **Symmetry**: The division method creates perfect bilateral symmetry along both axes

The resulting patterns show emergent complexity—simple rules creating intricate designs reminiscent of fractal geometry and traditional textile patterns. Because the color selection depends on corner colors (which themselves were chosen by the same algorithm), there's a cascading effect of color relationships throughout the entire design.

## Usage

1. Run the sketch to generate a pattern with a randomly selected palette.
2. Press the spacebar to cycle through different color palettes.
3. Each new pattern is saved as a JPG file with the palette number.

## Customization

### Changing the Grid Size

Modify the `n` variable to change the complexity of the pattern:
- n = 8 gives a 257×257 canvas
- n = 9 gives a 513×513 canvas 
- n = 10 gives a 1025×1025 canvas

```processing
int n = 9;  // Change this to adjust pattern complexity
int canvasSize = 513;  // Make sure this matches 2^n + 1
```

### Adding Custom Color Palettes

Use the `addCustomPalette()` function to add your own color palette:

```processing
// Create a new palette with your own hex colors
String[] myPalette = {"FF0000", "00FF00", "0000FF", "FFFF00", 
                      "FF00FF", "00FFFF", "000000", "FFFFFF",
                      "888888", "AAAAAA", "444444", "CCCCCC"};
                      
// Add it to the available palettes
addCustomPalette(myPalette);
```

## Color Palettes

The program includes these built-in palettes:

1. **Purple Gradient**: Smooth transition from deep purple to light gray
2. **Red to Teal**: Contrasting vibrant reds and teals
3. **Blue and Orange**: Deep blues paired with warm oranges
4. **Purple and Brown**: Royal purples with earthy browns
5. **Teal and Orange with Accents**: Coastal colors with black and white accents
6. **Nature-inspired**: Forest greens, earth tones, and sky blues
7. **Sunset**: Dark to vibrant colors mimicking sunset hues
8. **Ocean**: Various blues and teals with white highlights
9. **Autumn**: Rich reds, oranges, yellows, and browns

## Technical Details

- The color index array (`colorIndexArray`) tracks which color is assigned to each grid line
- Border drawing establishes the initial rectangle frame with the first color in the palette
- The recursive `chooseColor()` function handles dividing space and coloring
- Hex color codes are converted to Processing color values using the `hexToColor()` function
- The algorithm has O(n²) space complexity because it stores a color for each grid point
- The time complexity is also O(n²) where n is the grid dimension, as each grid line is processed exactly once

### Code Implementation Details

The algorithm's core functions work as follows:

1. **drawBorder()**: Creates the initial rectangular border and sets the color indices for all border points.

2. **chooseColor()**: The heart of the algorithm that:
   - Takes a rectangle defined by its corners (left, right, top, bottom)
   - Calculates the midpoints and new color index
   - Draws horizontal and vertical dividing lines
   - Updates the color index array for all points on these lines
   - Recursively calls itself on the four resulting sub-rectangles

3. **generatePaletteFromHexArray()**: Converts an array of hex color codes into Processing color objects.

The elegance of this algorithm lies in how simple rules generate complex, harmonious patterns. The color selection formula ensures that adjacent sections have related colors, while the shift value introduces enough variation to create visual interest throughout the design.

## Example Output

Running the program produces geometric patterns reminiscent of traditional Persian rugs, with complex symmetrical designs and harmonious color relationships.

```
// Example pattern generation
void setup() {
  size(513, 513);
  // Pattern generation code follows...
}
```

Each generated image will have its own unique character depending on the palette chosen and the random shift value used in the coloring algorithm.
