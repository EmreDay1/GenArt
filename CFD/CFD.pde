int IX(int x, int y) {
  return x + y * W;
}

void SWAP(float[] x0, float[] x) {
  for (int i = 0; i < x0.length; i++) {
    float tmp = x0[i];
    x0[i] = x[i];
    x[i] = tmp;
  }
}

void add_source(int N, float[] x, float[] s, float dt) {
  int size = (N + 2) * (N + 2);
  for (int i = 0; i < size; i++) {
    x[i] += dt * s[i];
  }
}

void set_bnd(int N, int b, float[] x) {
  for (int i = 1; i <= N; i++) {
    x[IX(0, i)] = b == 1 ? -x[IX(1, i)] : x[IX(1, i)];
    x[IX(N + 1, i)] = b == 1 ? -x[IX(N, i)] : x[IX(N, i)];
    x[IX(i, 0)] = b == 2 ? -x[IX(i, 1)] : x[IX(i, 1)];
    x[IX(i, N + 1)] = b == 2 ? -x[IX(i, N)] : x[IX(i, N)];
  }

  x[IX(0, 0)] = 0.5f * (x[IX(1, 0)] + x[IX(0, 1)]);
  x[IX(0, N + 1)] = 0.5f * (x[IX(1, N + 1)] + x[IX(0, N)]);
  x[IX(N + 1, 0)] = 0.5f * (x[IX(N, 0)] + x[IX(N + 1, 1)]);
  x[IX(N + 1, N + 1)] = 0.5f * (x[IX(N, N + 1)] + x[IX(N + 1, N)]);
}

void lin_solve(int N, int b, float[] x, float[] x0, float a, float c) {
  for (int k = 0; k < 20; k++) {
    for (int i = 1; i <= N; i++) {
      for (int j = 1; j <= N; j++) {
        x[IX(i, j)] = (x0[IX(i, j)] + a * (x[IX(i - 1, j)] + x[IX(i + 1, j)] + x[IX(i, j - 1)] + x[IX(i, j + 1)])) / c;
      }
    }
    set_bnd(N, b, x);
  }
}

void diffuse(int N, int b, float[] x, float[] x0, float diff, float dt) {
  float a = dt * diff * N * N;
  lin_solve(N, b, x, x0, a, 1 + 4 * a);
}

void advect(int N, int b, float[] d, float[] d0, float[] u, float[] v, float dt) {
  float dt0 = dt * N;
  for (int i = 1; i <= N; i++) {
    for (int j = 1; j <= N; j++) {
      float x = i - dt0 * u[IX(i, j)];
      float y = j - dt0 * v[IX(i, j)];
      if (x < 0.5f) x = 0.5f;
      if (x > N + 0.5f) x = N + 0.5f;
      int i0 = (int) x;
      int i1 = i0 + 1;
      if (y < 0.5f) y = 0.5f;
      if (y > N + 0.5f) y = N + 0.5f;
      int j0 = (int) y;
      int j1 = j0 + 1;
      float s1 = x - i0;
      float s0 = 1 - s1;
      float t1 = y - j0;
      float t0 = 1 - t1;
      d[IX(i, j)] = s0 * (t0 * d0[IX(i0, j0)] + t1 * d0[IX(i0, j1)]) + s1 * (t0 * d0[IX(i1, j0)] + t1 * d0[IX(i1, j1)]);
    }
  }
  set_bnd(N, b, d);
}

void project(int N, float[] u, float[] v, float[] p, float[] div) {
  for (int i = 1; i <= N; i++) {
    for (int j = 1; j <= N; j++) {
      div[IX(i, j)] = -0.5f * (u[IX(i + 1, j)] - u[IX(i - 1, j)] + v[IX(i, j + 1)] - v[IX(i, j - 1)]) / N;
      p[IX(i, j)] = 0;
    }
  }
  set_bnd(N, 0, div);
  set_bnd(N, 0, p);
  lin_solve(N, 0, p, div, 1, 4);
  for (int i = 1; i <= N; i++) {
    for (int j = 1; j <= N; j++) {
      u[IX(i, j)] -= 0.5f * N * (p[IX(i + 1, j)] - p[IX(i - 1, j)]);
      v[IX(i, j)] -= 0.5f * N * (p[IX(i, j + 1)] - p[IX(i, j - 1)]);
    }
  }
  set_bnd(N, 1, u);
  set_bnd(N, 2, v);
}

void dens_step(int N, float[] x, float[] x0, float[] u, float[] v, float diff, float dt) {
  add_source(N, x, x0, dt);
  SWAP(x0, x);
  diffuse(N, 0, x, x0, diff, dt);
  SWAP(x0, x);
  advect(N, 0, x, x0, u, v, dt);
}

void vel_step(int N, float[] u, float[] v, float[] u0, float[] v0, float visc, float dt) {
  add_source(N, u, u0, dt);
  add_source(N, v, v0, dt);
  SWAP(u0, u);
  diffuse(N, 1, u, u0, visc, dt);
  SWAP(v0, v);
  diffuse(N, 2, v, v0, visc, dt);
  project(N, u, v, u0, v0);
  SWAP(u0, u);
  SWAP(v0, v);
  advect(N, 1, u, u0, u0, v0, dt);
  advect(N, 2, v, v0, u0, v0, dt);
  project(N, u, v, u0, v0);
}

final int N = 64;
final int W = N + 2;
final int H = N + 2;
final int size = W * H;

float[] u = new float[size];
float[] v = new float[size];
float[] u_prev = new float[size];
float[] v_prev = new float[size];
float[] dens = new float[size];
float[] dens_prev = new float[size];

float dt = 0.1f;
float diff = 0.0f;
float visc = 0.0f;
float force = 1.0f;
float source = 100.0f;

void settings() {
  size(W * 10, H * 10);
}

void setup() {}

void get_from_UI(float[] d, float[] u, float[] v) {
  if (!mousePressed) return;
  int i = mouseX / 10;
  int j = mouseY / 10;
  if (i < 1 || i > N || j < 1 || j > N) return;
  u[IX(i, j)] = force * (mouseX - pmouseX);
  v[IX(i, j)] = force * (mouseY - pmouseY);
}

void mouseReleased() {
  int i = mouseX / 10;
  int j = mouseY / 10;
  dens_prev[IX(i, j)] = source;
}

void draw() {
  background(0);
  get_from_UI(dens_prev, u_prev, v_prev);
  vel_step(N, u, v, u_prev, v_prev, visc, dt);
  dens_step(N, dens, dens_prev, u, v, diff, dt);
  velocity();
}

void velocity() {
  float h = 10;
  stroke(255);
  for (int i = 1; i <= N; i++) {
    float x = i * h + h / 2;
    for (int j = 1; j <= N; j++) {
      float y = j * h + h / 2;
      float x2 = x + u[IX(i, j)] * 10;
      float y2 = y + v[IX(i, j)] * 10;
      line(x, y, x2, y2);
    }
  }
}
