int n = 9;
int canvasSize = 513;
int[][] colorIndexArray;
color[] palette;

String[][] colorPalettes = {
  {"6A2962", "70367D", "69438E", "60519E", "666FA9", "7D94B0", "94AFB8", "A9C1BF", "BDCBC6", "D0D7D2", "E2E4E2", "F2F2F2"},
  {"4C0000", "700106", "930112", "B70122", "DA0137", "FE0151", "004C4C", "017068", "019380", "01B792", "01DAA0", "01FEAA"},
  {"011C40", "022859", "023373", "01438C", "0153A5", "0162BF", "8C4F00", "A65E00", "BF6D00", "D97C00", "F28C00", "FF9B0D"},
  {"2F1847", "532B69", "803D95", "BE4ECA", "D282D9", "E2AEE5", "472F18", "694A2B", "95693D", "CA864E", "D9AE82", "E5CEB1"},
  {"005F73", "0A9396", "94D2BD", "E9D8A6", "EE9B00", "CA6702", "BB3E03", "AE2012", "9B2226", "FFFFFF", "555555", "000000"},
  {"264653", "2A9D8F", "E9C46A", "F4A261", "E76F51", "FFFFFF", "000000", "597D35", "A3C9A8", "DDE7C7", "BFA89E", "8E7F7F"},
  {"050505", "1A1423", "3D314A", "684756", "96705B", "AB8476", "CDAB7E", "FCFF4B", "FF5E5B", "D8405D", "8D3B72", "351E29"},
  {"022B3A", "1F7A8C", "BFDBF7", "E1E5F2", "FFFFFF", "A8DCD9", "6FFFE9", "5BC0BE", "3A506B", "1C2541", "0B132B", "030027"},
  {"370617", "6A040F", "9D0208", "D00000", "DC2F02", "E85D04", "F48C06", "FAA307", "FFBA08", "EBD38C", "D4B483", "7D5A50"}
};

int currentPaletteIndex = 0;

void setup() {
  size(513, 513);
  currentPaletteIndex = floor(random(colorPalettes.length));
  palette = generatePaletteFromHexArray(colorPalettes[currentPaletteIndex]);
  colorIndexArray = new int[canvasSize][canvasSize];
  int w = canvasSize - 1;
  drawBorder(1, 1, w, w, 0);
  int shift = floor(random(1, palette.length));
  chooseColor(1, w, 1, w, shift);
  save("persian_rug.jpg");
  noLoop();
}

void draw() {
}

void keyPressed() {
  if (key == ' ') {
    currentPaletteIndex = (currentPaletteIndex + 1) % colorPalettes.length;
    palette = generatePaletteFromHexArray(colorPalettes[currentPaletteIndex]);
    colorIndexArray = new int[canvasSize][canvasSize];
    background(255);
    int w = canvasSize - 1;
    drawBorder(1, 1, w, w, 0);
    int shift = floor(random(1, palette.length));
    chooseColor(1, w, 1, w, shift);
    save("persian_rug_palette_" + currentPaletteIndex + ".jpg");
  }
}

void drawBorder(int left, int top, int right, int bottom, int colorIndex) {
  color c = palette[colorIndex];
  stroke(c);
  line(left, top, right, top);
  line(left, bottom, right, bottom);
  line(left, top, left, bottom);
  line(right, top, right, bottom);
  for (int i = left; i <= right; i++) {
    colorIndexArray[i][top] = colorIndex;
    colorIndexArray[i][bottom] = colorIndex;
  }
  for (int i = top; i <= bottom; i++) {
    colorIndexArray[left][i] = colorIndex;
    colorIndexArray[right][i] = colorIndex;
  }
}

void chooseColor(int left, int right, int top, int bottom, int shift) {
  if (left < right - 1) {
    int newIndex = (colorIndexArray[left][top] +
                    colorIndexArray[right][top] +
                    colorIndexArray[left][bottom] +
                    colorIndexArray[right][bottom] +
                    shift) % palette.length;
    color col = palette[newIndex];
    int midCol = (left + right) / 2;
    int midRow = (top + bottom) / 2;
    stroke(col);
    line(left + 1, midRow, right - 1, midRow);
    line(midCol, top + 1, midCol, bottom - 1);
    for (int i = left + 1; i < right; i++) {
      colorIndexArray[i][midRow] = newIndex;
    }
    for (int i = top + 1; i < bottom; i++) {
      colorIndexArray[midCol][i] = newIndex;
    }
    chooseColor(left, midCol, top, midRow, shift);
    chooseColor(midCol, right, top, midRow, shift);
    chooseColor(left, midCol, midRow, bottom, shift);
    chooseColor(midCol, right, midRow, bottom, shift);
  }
}

color[] generatePaletteFromHexArray(String[] hexCodes) {
  color[] result = new color[hexCodes.length];
  for (int i = 0; i < hexCodes.length; i++) {
    result[i] = hexToColor(hexCodes[i]);
  }
  return result;
}

color hexToColor(String hex) {
  int r = unhex(hex.substring(0, 2));
  int g = unhex(hex.substring(2, 4));
  int b = unhex(hex.substring(4, 6));
  return color(r, g, b);
}

void addCustomPalette(String[] hexColors) {
  String[][] newColorPalettes = new String[colorPalettes.length + 1][];
  arrayCopy(colorPalettes, newColorPalettes, colorPalettes.length);
  newColorPalettes[colorPalettes.length] = hexColors;
  colorPalettes = newColorPalettes;
}
