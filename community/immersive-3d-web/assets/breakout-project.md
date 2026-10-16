# breakout-project — Breakout Frame 3D

Vite + TypeScript project. Copy the files below and run `npm install && npm run dev`.

## package.json

```json
{
  "name": "breakout-3d-template",
  "private": true,
  "version": "1.0.0",
  "description": "Breakout Frame 3D — immersive Three.js + GSAP + Lenis template",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "gsap": "^3.12.5",
    "lenis": "^1.1.13",
    "three": "^0.160.0"
  },
  "devDependencies": {
    "@types/three": "^0.160.0",
    "typescript": "^5.5.0",
    "vite": "^5.4.0"
  }
}
```

## vite.config.ts

```typescript
import { defineConfig } from "vite";

export default defineConfig({
  server: {
    port: 5173,
    open: true,
  },
  build: {
    target: "es2020",
  },
});
```

## tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "module": "ESNext",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "strict": true,
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src"]
}
```

## index.html

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Breakout Frame 3D — Immersive Web</title>
    <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🎩</text></svg>" />
  </head>
  <body>
    <!-- Canvas 3D — fixed, pointer-events none -->
    <div id="three-canvas"></div>

    <!-- Contenido con scroll -->
    <main class="content">
      <!-- HERO -->
      <section>
        <h1>🚗 Breakout Frame 3D</h1>
        <p>Objetos que SALEN de la pantalla. Parallax 3D con <strong>Three.js + GSAP + Lenis</strong>.</p>
        <p class="hint">Scrollea para ver el efecto</p>
      </section>

      <section class="section-spacer"></section>

      <!-- FEATURES -->
      <section>
        <h2>Cómo funciona</h2>
        <div class="card-grid">
          <div class="card">
            <h3>🎯 Depth Parallax</h3>
            <p>Capas a diferentes profundidades Z se mueven a velocidades distintas. Las más cercanas "salen" de la pantalla.</p>
          </div>
          <div class="card">
            <h3>🔄 Scroll-Driven</h3>
            <p>GSAP ScrollTrigger sincroniza la animación 3D con el scroll. Scrub 1.5 para fluidez cinematográfica.</p>
          </div>
          <div class="card">
            <h3>🌊 Lenis Smooth</h3>
            <p>Smooth scrolling a 60fps con física. Sin Lenis el parallax se siente entrecortado.</p>
          </div>
        </div>
      </section>

      <section class="section-spacer"></section>

      <!-- FOOTER -->
      <section>
        <h2>¿Listo para crear?</h2>
        <p>Usá este template como base para tu próximo sitio 3D inmersivo.</p>
        <p class="footer-note">🎩 Gentleman Programming — Skill immersive-3d-web</p>
      </section>
    </main>

    <script type="module" src="/src/main.ts"></script>
  </body>
</html>
```

## src/main.ts

```typescript
/**
 * Breakout Frame 3D — Main Scene
 *
 * Three.js + GSAP + Lenis — Immersive Parallax Experience
 *
 * Para correrlo:
 *   npm install
 *   npm run dev
 *
 * Abrí http://localhost:5173 en el navegador.
 */

import * as THREE from "three";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import Lenis from "lenis";

import "./style.css";

// ============================================================
// SETUP
// ============================================================
gsap.registerPlugin(ScrollTrigger);

const CONFIG = {
  cameraFov: 50,
  cameraZ: 15,
  fogColor: 0x0a0a0a,
  fogNear: 12,
  fogFar: 30,
};

// ============================================================
// 1. LENIS — Smooth Scroll
// ============================================================
const lenis = new Lenis({
  duration: 1.2,
  easing: (t: number) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
  orientation: "vertical",
  smoothWheel: true,
});

function raf(time: number) {
  lenis.raf(time);
  requestAnimationFrame(raf);
}
requestAnimationFrame(raf);

// ============================================================
// 2. THREE.JS — 3D Scene
// ============================================================
const container = document.getElementById("three-canvas")!;
const scene = new THREE.Scene();

const camera = new THREE.PerspectiveCamera(
  CONFIG.cameraFov,
  window.innerWidth / window.innerHeight,
  0.1,
  100
);
camera.position.set(0, 0, CONFIG.cameraZ);

const renderer = new THREE.WebGLRenderer({
  antialias: true,
  alpha: true,
});
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.5;
container.appendChild(renderer.domElement);

// ============================================================
// 3. LIGHTS
// ============================================================
scene.add(new THREE.AmbientLight(0x404060, 0.5));

const dirLight = new THREE.DirectionalLight(0xffffff, 1.5);
dirLight.position.set(5, 10, 7);
scene.add(dirLight);

const backLight = new THREE.DirectionalLight(0x4466ff, 0.8);
backLight.position.set(-5, 0, -5);
scene.add(backLight);

// ============================================================
// 4. 3D OBJECTS — Parallax Layers
// ============================================================

/**
 * Parallax Layer: cada capa tiene un mesh y una velocidad.
 * Velocidad más alta = el objeto se mueve más rápido con el scroll
 * = parece estar más cerca = efecto "breakout" (sale de la pantalla)
 */
interface Layer {
  mesh: THREE.Object3D;
  speed: number;
}

const layers: Layer[] = [];

// --- CAPA 1: Fondo — wireframe icosaedro (MUY lento) ---
const bgMesh = new THREE.Mesh(
  new THREE.IcosahedronGeometry(4, 1),
  new THREE.MeshStandardMaterial({
    color: 0x2233aa,
    wireframe: true,
    transparent: true,
    opacity: 0.15,
  })
);
bgMesh.position.z = -15;
scene.add(bgMesh);
layers.push({ mesh: bgMesh, speed: 0.05 });

// --- CAPA 2: Anillos flotantes (velocidad media) ---
for (let i = 0; i < 8; i++) {
  const ring = new THREE.Mesh(
    new THREE.TorusGeometry(1 + i * 0.4, 0.05, 16, 32),
    new THREE.MeshStandardMaterial({
      color: new THREE.Color().setHSL(i * 0.12, 0.8, 0.6),
      transparent: true,
      opacity: 0.3 + i * 0.05,
    })
  );
  ring.position.set(
    Math.cos(i * 0.8) * 6,
    Math.sin(i * 0.8) * 6 - 2,
    -5 + i * 0.3
  );
  ring.rotation.x = Math.PI * 0.3;
  ring.rotation.z = i * 0.5;
  scene.add(ring);
  layers.push({ mesh: ring, speed: 0.15 });
}

// --- CAPA 3: Cubo central BREAKOUT (velocidad ALTA = sale de la pantalla) ---
const box = new THREE.Mesh(
  new THREE.BoxGeometry(1.5, 1.5, 1.5),
  new THREE.MeshStandardMaterial({
    color: 0xff4477,
    metalness: 0.8,
    roughness: 0.2,
    emissive: 0xff2244,
    emissiveIntensity: 0.2,
  })
);
box.position.set(0, 0, 3); // ← Z positivo = más cerca de la cámara
scene.add(box);
layers.push({ mesh: box, speed: 0.25 });

// --- Satélites orbitando el cubo ---
for (let i = 0; i < 6; i++) {
  const sat = new THREE.Mesh(
    new THREE.SphereGeometry(0.15, 8, 8),
    new THREE.MeshStandardMaterial({
      color: 0x66ddff,
      emissive: 0x4488ff,
      emissiveIntensity: 0.5,
    })
  );
  sat.userData = { angle: (i / 6) * Math.PI * 2, radius: 2 };
  sat.position.z = 3;
  scene.add(sat);
  layers.push({ mesh: sat, speed: 0.25 });
}

// --- CAPA 4: Partículas (velocidad MUY ALTA = breakout extremo) ---
const particleCount = 300;
const positions = new Float32Array(particleCount * 3);
for (let i = 0; i < particleCount * 3; i++) {
  positions[i] = (Math.random() - 0.5) * 30;
}
const particles = new THREE.Points(
  new THREE.BufferGeometry().setAttribute(
    "position",
    new THREE.BufferAttribute(positions, 3)
  ),
  new THREE.PointsMaterial({
    color: 0x88aaff,
    size: 0.08,
    transparent: true,
    opacity: 0.6,
    sizeAttenuation: true,
  })
);
particles.position.z = 3;
scene.add(particles);
layers.push({ mesh: particles, speed: 0.35 });

console.log(`🎯 ${layers.length} parallax layers created`);

// ============================================================
// 5. SCROLL CONNECT — Parallax via Lenis
// ============================================================
lenis.on("scroll", (e: any) => {
  const y = e.animatedScroll ?? e.targetScroll ?? 0;

  // Mover cada capa a su velocidad
  layers.forEach(({ mesh, speed }) => {
    mesh.position.y = -y * speed;
  });

  // Efectos extra
  bgMesh.rotation.y = y * 0.002;

  // Satélites: orbitan mientras scrolleás
  for (const child of scene.children) {
    if (child.userData?.angle !== undefined) {
      const sat = child as THREE.Mesh;
      const newAngle = sat.userData.angle + y * 0.003;
      sat.position.x = Math.cos(newAngle) * sat.userData.radius;
      sat.position.y = Math.sin(newAngle) * sat.userData.radius - y * 0.25;
    }
  }
});

// ============================================================
// 6. GSAP SCROLLTRIGGER — Animación 3D adicional
// ============================================================
gsap.to(box.rotation, {
  y: Math.PI * 4,
  x: Math.PI * 2,
  scrollTrigger: {
    trigger: "body",
    start: "top top",
    end: "bottom bottom",
    scrub: 1.5,
  },
});

gsap.to(box.scale, {
  x: 1.5,
  y: 1.5,
  z: 1.5,
  scrollTrigger: {
    trigger: "body",
    start: "top top",
    end: "bottom bottom",
    scrub: 1.5,
  },
});

// ============================================================
// 7. ANIMATION LOOP
// ============================================================
function animate() {
  requestAnimationFrame(animate);

  const time = Date.now() * 0.001;

  // Auto-rotación de anillos
  scene.children.forEach((child) => {
    if (child.type === "Mesh" && child !== box && child !== bgMesh) {
      const mesh = child as THREE.Mesh;
      if (mesh.geometry.type === "TorusGeometry") {
        mesh.rotation.y += 0.005;
      }
    }
  });

  // Pulsación suave del cubo
  // NOTA: Si GSAP está animando el scale via ScrollTrigger,
  // esta pulsación se suma suavemente al efecto.
  const pulse = 1 + Math.sin(time * 3) * 0.04;
  box.scale.x = pulse;
  box.scale.y = pulse;
  box.scale.z = pulse;

  renderer.render(scene, camera);
}
animate();

// ============================================================
// 8. RESIZE
// ============================================================
window.addEventListener("resize", () => {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
});

console.log("🚀 Breakout Frame 3D corriendo!");
console.log("📦 Stack: Three.js + GSAP ScrollTrigger + Lenis");
```

## src/style.css

```css
/* === BREAKOUT FRAME 3D — STYLES === */

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html.lenis {
  height: auto;
}

body {
  font-family: system-ui, -apple-system, sans-serif;
  background: #0a0a0a;
  color: #ffffff;
  overflow-x: hidden;
}

/* Canvas 3D — fixed, siempre detras del contenido */
#three-canvas {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  z-index: 0;
  pointer-events: none;
}

/* Contenido por encima del canvas */
.content {
  position: relative;
  z-index: 1;
}

/* Section */
section {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 4rem 2rem;
}

.section-spacer {
  min-height: 50vh;
}

/* Typography */
h1 {
  font-size: clamp(2rem, 5vw, 4rem);
  text-align: center;
  max-width: 800px;
  line-height: 1.2;
  font-weight: 800;
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 50%, #4facfe 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

h2 {
  font-size: clamp(1.5rem, 3vw, 2.5rem);
  text-align: center;
  margin-bottom: 2rem;
  font-weight: 700;
}

p {
  font-size: clamp(1rem, 2vw, 1.25rem);
  max-width: 600px;
  text-align: center;
  margin-top: 1rem;
  opacity: 0.7;
  line-height: 1.6;
}

.hint {
  font-size: 0.85rem;
  opacity: 0.4;
  margin-top: 2rem;
}

.footer-note {
  font-size: 0.85rem;
  margin-top: 2rem;
  opacity: 0.3;
}

/* Cards grid */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
  max-width: 1000px;
  width: 100%;
  margin-top: 1rem;
}

.card {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 1rem;
  padding: 2rem;
  transition: transform 0.3s ease;
}

.card:hover {
  transform: translateY(-4px);
}

.card h3 {
  font-size: 1.5rem;
  margin-bottom: 0.5rem;
  background: linear-gradient(135deg, #f093fb, #f5576c);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.card p {
  font-size: 0.95rem;
  text-align: left;
  margin-top: 0;
  opacity: 0.6;
}

/* Scroll indicator */
@media (prefers-reduced-motion: reduce) {
  #three-canvas {
    display: none;
  }
}
```

## src/vite-env.d.ts

```typescript
/// <reference types="vite/client" />
```
