// Based on algorithm by Roger Penrose


// Global Variables
float goldenRatio;
ArrayList<PenroseTile> tiles;
int maxDepth = 7;
int currentDepth = 0;
int subdivisionMethod = 1;
boolean autoAnimate = false;
float rotationAngle = 0;
float zoom = 1.0;
int currentColorScheme = 0;
float hueShift = 0;
float glowIntensity = 0.5; // Reduced for white background
float pulseAmount = 0;
boolean showUI = true;
boolean showGlow = true;
boolean useCurvedTiles = false;
PGraphics tileLayer;
PGraphics glowLayer;
boolean gradientBackground = false; // Default to flat white background

// Color schemes with names (pairs for the two tile types)
String[] colorSchemeNames = {"Classic", "Cosmic", "Sunset", "Neon", "Rainbow", "Gold & Silver"};
color[][] colorSchemes = {
  {color(200, 0, 0), color(0, 0, 200)},            // Classic
  {color(20, 0, 80), color(80, 0, 150)},           // Cosmic
  {color(255, 80, 0), color(200, 0, 80)},          // Sunset
  {color(0, 200, 170), color(180, 0, 220)},        // Neon
  {color(0, 0, 0), color(0, 0, 0)},                // Rainbow (dynamic)
  {color(218, 165, 32), color(120, 120, 120)}      // Gold & Silver
};

// UI Variables
PVector uiPosition;
int uiWidth = 200;
boolean uiCollapsed = false;
float uiOpacity = 220; // 0-255, increased for better visibility on white

// Setup
void setup() {
  size(1200, 900, P2D);  // P2D renderer for better performance
  pixelDensity(displayDensity());  // For high-DPI displays
  colorMode(HSB, 360, 100, 100, 100);
  goldenRatio = (1.0 + sqrt(5)) / 2.0;
  
  // Create layers for rendering
  tileLayer = createGraphics(width, height, P2D);
  tileLayer.colorMode(HSB, 360, 100, 100, 100);
  glowLayer = createGraphics(width, height, P2D);
  glowLayer.colorMode(HSB, 360, 100, 100, 100);
  
  resetTiles();
  
  textSize(16);
  textAlign(LEFT, TOP);
  uiPosition = new PVector(20, 20);
  
  // Generate a few levels to start with something interesting
  for (int i = 0; i < 3; i++) {
    generate();
  }
}

void draw() {
  // Calculate effects (once per frame)
  pulseAmount = sin(frameCount * 0.02) * 0.1 + 0.9; // Breathing effect
  if (autoAnimate) {
    hueShift = (hueShift + 0.3) % 360;
    rotationAngle += 0.001;
  }
  
  // Clear the background to white
  if (gradientBackground) {
    drawGradientBackground();
  } else {
    background(0, 0, 100); // White in HSB
  }
  
  // Update rainbow colors if needed (only when using rainbow scheme)
  if (currentColorScheme == 4) {
    updateRainbowColors();
  }
  
  // Draw to tile layer
  tileLayer.beginDraw();
  tileLayer.clear();
  tileLayer.pushMatrix();
  tileLayer.translate(width/2, height/2);
  tileLayer.rotate(rotationAngle);
  tileLayer.scale(zoom * pulseAmount);
  
  // Draw all tiles
  for (PenroseTile t : tiles) {
    t.display(tileLayer);
  }
  
  tileLayer.popMatrix();
  tileLayer.endDraw();
  
  // Draw glow effect (optional)
  if (showGlow) {
    drawGlowEffect();
  }
  
  // Draw the tile layer
  image(tileLayer, 0, 0);
  
  // Draw UI
  if (showUI) {
    drawUI();
  }
}

void drawGradientBackground() {
  // Create a light gradient suitable for white background
  color center, edge;
  if (currentColorScheme == 4) { // Rainbow
    center = color((hueShift + 180) % 360, 15, 100); // Light center
    edge = color(hueShift, 25, 90); // Light edge
  } else {
    // Get colors from current scheme
    color baseColor = colorSchemes[currentColorScheme][0];
    float h = hue(baseColor);
    center = color(h, 15, 100); // Light center
    edge = color(h, 30, 90); // Light edge
  }
  
  // Optimized gradient drawing with fewer rings
  background(edge);
  int steps = 50; // Reduced number of rings
  for (int i = 0; i < steps; i++) {
    float ratio = 1.0 - (float)i / steps;
    color ringColor = lerpColor(center, edge, ratio);
    noFill();
    stroke(ringColor);
    strokeWeight(max(width, height)/steps * 1.5);
    ellipse(width/2, height/2, ratio * max(width, height) * 2, ratio * max(width, height) * 2);
  }
}

void drawGlowEffect() {
  // Create a blurred version of the tile layer for the glow effect
  glowLayer.beginDraw();
  glowLayer.clear();
  glowLayer.imageMode(CORNER);
  glowLayer.image(tileLayer, 0, 0);
  glowLayer.filter(BLUR, 12);
  glowLayer.endDraw();
  
  // Blend the glow layer with the main display
  blendMode(ADD);
  tint(255, glowIntensity * 60); // Reduced for white background
  image(glowLayer, 0, 0);
  blendMode(NORMAL);
  tint(255, 255);
}

void drawUI() {
  // Draw semi-transparent UI panel with darker colors for white background
  pushStyle();
  float panelHeight = uiCollapsed ? 30 : 250;
  
  // Panel background - darker for white background
  fill(210, 30, 40, uiOpacity); // Dark blue-gray
  stroke(0, 0, 30, 80);
  strokeWeight(1);
  rect(uiPosition.x, uiPosition.y, uiWidth, panelHeight, 10);
  
  // Draw header bar
  fill(210, 40, 30, uiOpacity); // Slightly darker header
  rect(uiPosition.x, uiPosition.y, uiWidth, 30, 10, 10, 0, 0);
  
  // Draw title - white text
  fill(0, 0, 100, 90);
  text("PENROSE FRACTAL ART", uiPosition.x + 10, uiPosition.y + 6);
  
  // Draw collapse/expand button
  fill(0, 0, 100, 70);
  text(uiCollapsed ? "+" : "-", uiPosition.x + uiWidth - 20, uiPosition.y + 6);
  
  if (!uiCollapsed) {
    // Draw info and controls
    fill(0, 0, 100, 80);
    float y = uiPosition.y + 40;
    text("Depth: " + currentDepth + "/" + maxDepth, uiPosition.x + 10, y); y += 20;
    text("Tiles: " + tiles.size(), uiPosition.x + 10, y); y += 20;
    text("Method: " + subdivisionMethod, uiPosition.x + 10, y); y += 20;
    text("Colors: " + colorSchemeNames[currentColorScheme], uiPosition.x + 10, y); y += 20;
    
    String status = autoAnimate ? "ANIMATING" : "PAUSED";
    fill(autoAnimate ? color(120, 70, 90) : color(0, 0, 70));
    text(status, uiPosition.x + 10, y); y += 30;
    
    // Draw controls section
    fill(0, 0, 100, 80); // White text
    text("CONTROLS", uiPosition.x + 10, y); y += 20;
    textSize(14);
    text("Click: Subdivide | SPACE: Reset", uiPosition.x + 10, y); y += 18;
    text("1/2: Change Method | C: Colors", uiPosition.x + 10, y); y += 18;
    text("A: Animate | R: Rotate | G: Glow", uiPosition.x + 10, y); y += 18;
    text("+/-: Zoom | S: Save | H: Hide UI", uiPosition.x + 10, y); y += 18;
    text("B: Background | E: Export PDF", uiPosition.x + 10, y);
    textSize(16);
  }
  popStyle();
}

void updateRainbowColors() {
  for (int i = 0; i < tiles.size(); i++) {
    PenroseTile t = tiles.get(i);
    
    // Calculate center of the tile once
    PVector center = new PVector(
      (t.a.x + t.b.x + t.c.x) / 3,
      (t.a.y + t.b.y + t.c.y) / 3
    );
    
    float dist = center.mag() / 300.0;
    float angle = atan2(center.y, center.x);
    
    // Calculate hue based on angle, distance and current shift
    float hue1 = (hueShift + angle * 180/PI + dist * 60) % 360;
    float hue2 = (hue1 + 180) % 360;
    
    // Set custom colors with high saturation for vibrant look
    t.customColor = (t.tileType == 0) ? 
      color(hue1, 90, 80) : // Slightly darker for white bg
      color(hue2, 80, 75);
  }
}

void resetTiles() {
  tiles = new ArrayList<PenroseTile>();
  currentDepth = 0;
  if (random(1) < 0.5) {
    seed1();
  } else {
    seed2();
  }
}

void generate() {
  if (currentDepth >= maxDepth) return;
  
  ArrayList<PenroseTile> next = new ArrayList<PenroseTile>();
  for (PenroseTile t : tiles) {
    PenroseTile[] more = (subdivisionMethod == 1) ? 
                         t.subdivide1() : 
                         t.subdivide2();
    for (PenroseTile newTile : more) {
      next.add(newTile);
    }
  }
  tiles = next;
  currentDepth++;
}

void seed1() {
  int numPoints = 10;
  for (int i = 0; i < numPoints; i++) {
    PVector a = new PVector();
    PVector b = PVector.fromAngle((2*i - 1) * PI / numPoints);
    PVector c = PVector.fromAngle((2*i + 1) * PI / numPoints);
    b.mult(350);
    c.mult(350);
    if (i % 2 == 0) {
      tiles.add(new PenroseTile(0, a, b, c));
    } else {
      tiles.add(new PenroseTile(0, a, c, b));
    }
  }
}

void seed2() {
  int numPoints = 10;
  for (int i = 0; i < numPoints; i++) {
    PVector a = new PVector();
    PVector b = PVector.fromAngle((2*i - 1) * PI / numPoints);
    PVector c = PVector.fromAngle((2*i + 1) * PI / numPoints);
    b.mult(350);
    c.mult(350);
    if (i % 2 == 0) {
      tiles.add(new PenroseTile(0, b, a, c));
    } else {
      tiles.add(new PenroseTile(0, c, a, b));
    }
  }
}

// UI and Input Handling
void mousePressed() {
  // Check if clicked in UI header (for dragging)
  if (mouseX >= uiPosition.x && mouseX <= uiPosition.x + uiWidth &&
      mouseY >= uiPosition.y && mouseY <= uiPosition.y + 30) {
    // Check collapse/expand button
    if (mouseX >= uiPosition.x + uiWidth - 30 && mouseX <= uiPosition.x + uiWidth) {
      uiCollapsed = !uiCollapsed;
    }
  } 
  // Otherwise generate more tiles
  else {
    generate();
  }
}

void mouseDragged() {
  // Allow dragging UI panel
  if (mouseX >= uiPosition.x && mouseX <= uiPosition.x + uiWidth &&
      mouseY >= uiPosition.y && mouseY <= uiPosition.y + 30) {
    uiPosition.x += mouseX - pmouseX;
    uiPosition.y += mouseY - pmouseY;
    
    // Keep on screen
    uiPosition.x = constrain(uiPosition.x, 0, width - uiWidth);
    uiPosition.y = constrain(uiPosition.y, 0, height - 30);
  }
}

void keyPressed() {
  if (key == ' ') {
    resetTiles();
  } else if (key == '1') {
    subdivisionMethod = 1;
    resetTiles();
  } else if (key == '2') {
    subdivisionMethod = 2;
    resetTiles();
  } else if (key == 'c' || key == 'C') {
    currentColorScheme = (currentColorScheme + 1) % colorSchemes.length;
  } else if (key == 'a' || key == 'A') {
    autoAnimate = !autoAnimate;
  } else if (key == 'r' || key == 'R') {
    rotationAngle += PI/5;
  } else if (key == 'g' || key == 'G') {
    showGlow = !showGlow;
  } else if (key == 'b' || key == 'B') {
    gradientBackground = !gradientBackground;
  } else if (key == 'h' || key == 'H') {
    showUI = !showUI;
  } else if (key == '+' || key == '=') {
    zoom *= 1.2;
  } else if (key == '-') {
    zoom /= 1.2;
  } else if (key == 's' || key == 'S') {
    saveFrame("penrose-fractal-####.png");
  } else if (key == 't' || key == 'T') {
    useCurvedTiles = !useCurvedTiles;
  }
}

// PenroseTile Class - Optimized
class PenroseTile {
  PVector a, b, c;
  int tileType;  // 0=red (half kite), 1=blue (half dart)
  color customColor = -1;  // For custom coloring
  float brightness;
  
  PenroseTile(int type, PVector a_, PVector b_, PVector c_) {
    tileType = type;
    a = a_.copy();
    b = b_.copy();
    c = c_.copy();
    brightness = random(0.85, 1.0);  // Slight random brightness
  }

  void display(PGraphics pg) {
    // Determine color to use
    color tileColor;
    if (customColor != -1) {
      tileColor = customColor;
    } else {
      tileColor = colorSchemes[currentColorScheme][tileType];
      // Apply brightness variation
      if (brightness != 1.0 && currentColorScheme != 4) {
        tileColor = adjustBrightness(tileColor, brightness * pulseAmount);
      }
    }
    
    // Draw the tile
    pg.noStroke();
    pg.fill(tileColor);
    
    if (useCurvedTiles) {
      // Get position of center point for curved tiles
      PVector center = new PVector(
        (a.x + b.x + c.x) / 3,
        (a.y + b.y + c.y) / 3
      );
      
      // Draw curved version (using Bezier curves)
      pg.beginShape();
      pg.vertex(a.x, a.y);
      
      // Bezier curve from A to B
      PVector controlAB = new PVector(
        a.x + (b.x - a.x) * 0.5 + (center.x - a.x - (b.x - a.x) * 0.5) * 0.2,
        a.y + (b.y - a.y) * 0.5 + (center.y - a.y - (b.y - a.y) * 0.5) * 0.2
      );
      pg.bezierVertex(controlAB.x, controlAB.y, controlAB.x, controlAB.y, b.x, b.y);
      
      // Bezier curve from B to C
      PVector controlBC = new PVector(
        b.x + (c.x - b.x) * 0.5 + (center.x - b.x - (c.x - b.x) * 0.5) * 0.2,
        b.y + (c.y - b.y) * 0.5 + (center.y - b.y - (c.y - b.y) * 0.5) * 0.2
      );
      pg.bezierVertex(controlBC.x, controlBC.y, controlBC.x, controlBC.y, c.x, c.y);
      
      // Bezier curve from C to A
      PVector controlCA = new PVector(
        c.x + (a.x - c.x) * 0.5 + (center.x - c.x - (a.x - c.x) * 0.5) * 0.2,
        c.y + (a.y - c.y) * 0.5 + (center.y - c.y - (a.y - c.y) * 0.5) * 0.2
      );
      pg.bezierVertex(controlCA.x, controlCA.y, controlCA.x, controlCA.y, a.x, a.y);
      
      pg.endShape(CLOSE);
    } else {
      // Draw regular triangle (faster)
      pg.triangle(a.x, a.y, b.x, b.y, c.x, c.y);
    }
    
    // Add subtle inner highlight for 3D effect
    if (currentColorScheme != 4 && !useCurvedTiles) {  // Skip for rainbow mode and curved tiles
      PVector innerPoint = new PVector(
        (a.x + b.x + c.x) / 3.5,
        (a.y + b.y + c.y) / 3.5
      );
      color highlight = adjustBrightness(tileColor, 1.3);
      pg.fill(highlight, 100);
      pg.noStroke();
      pg.ellipse(innerPoint.x, innerPoint.y, 5, 5);
    }
    
    // Add edge outline for better visibility on white background
    if (currentColorScheme == 5 || brightness < 0.9) {  // Gold & Silver or darker tiles
      pg.strokeWeight(0.5);
      pg.stroke(0, 0, 40, 20); // Very subtle dark outline
      pg.noFill();
      pg.triangle(a.x, a.y, b.x, b.y, c.x, c.y);
    }
  }
  
  // Simple brightness adjustment
  color adjustBrightness(color c, float factor) {
    float h = hue(c);
    float s = saturation(c);
    float b = brightness(c) * factor;
    return color(h, s, constrain(b, 0, 100));
  }

  PenroseTile[] subdivide1() {
    if (tileType == 0) {
      // Subdivide red triangle (half kite)
      PVector p = PVector.sub(b, a).div(goldenRatio).add(a);
      
      PenroseTile[] result = new PenroseTile[2];
      result[0] = new PenroseTile(0, c, p, b);
      result[1] = new PenroseTile(1, p, c, a);
      return result;
    } else {
      // Subdivide blue triangle (half dart)
      PVector q = PVector.sub(a, b).div(goldenRatio).add(b);
      PVector r = PVector.sub(c, b).div(goldenRatio).add(b);
      
      PenroseTile[] result = new PenroseTile[3];
      result[0] = new PenroseTile(1, r, c, a);
      result[1] = new PenroseTile(1, q, r, b);
      result[2] = new PenroseTile(0, r, q, a);
      return result;
    }
  }

  PenroseTile[] subdivide2() {
    if (tileType == 0) {
      // Subdivide red triangle (half kite)
      PVector q = PVector.sub(b, a).div(goldenRatio).add(a);
      PVector r = PVector.sub(c, b).div(goldenRatio).add(b);
      
      PenroseTile[] result = new PenroseTile[3];
      result[0] = new PenroseTile(1, r, q, b);
      result[1] = new PenroseTile(0, q, a, r);
      result[2] = new PenroseTile(0, c, a, r);
      return result;
    } else {
      // Subdivide blue triangle (half dart)
      PVector p = PVector.sub(a, c).div(goldenRatio).add(c);
      
      PenroseTile[] result = new PenroseTile[2];
      result[0] = new PenroseTile(1, b, p, a);
      result[1] = new PenroseTile(0, p, c, b);
      return result;
    }
  }
}
