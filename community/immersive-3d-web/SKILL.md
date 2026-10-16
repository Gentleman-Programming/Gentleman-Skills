---
name: immersive-3d-web
description: >
  Three.js + GSAP + ScrollTrigger + Lenis patterns for immersive 3D web experiences.
  Trigger: When creating 3D web experiences, Three.js scenes, GSAP ScrollTrigger animations,
  breakout-frame effects, 3D parallax, scroll-driven 3D, or Japanese-style immersive websites.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## Core Stack (REQUIRED)

```typescript
// Install these — the "Gentleman 3D" stack
// npm create vite@latest . -- --template vanilla-ts
// npm install three @types/three gsap lenis
```

| Tool | Purpose | Why |
|------|---------|-----|
| **Three.js** | 3D rendering in browser | WebGL abstraction, scene graph, camera control |
| **GSAP** | High-performance timeline animations | ScrollTrigger plugin for scroll-driven animation |
| **Lenis** | Smooth scrolling with physics | Replaces native scroll for buttery 60fps parallax |
| **@studio-freight/lenis** | Lenis React / Next.js | If using React/Astro islands |

## Lenis — Smooth Scroll (REQUIRED)

**MUST be set up FIRST** before any scroll-driven effects. Without it, 3D parallax feels jagged.

```typescript
import Lenis from "lenis";

const lenis = new Lenis({
  duration: 1.2,
  easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
  orientation: "vertical",
  smoothWheel: true,
});

// RAF loop — CRITICAL
function raf(time: number) {
  lenis.raf(time);
  requestAnimationFrame(raf);
}
requestAnimationFrame(raf);

// Sync Three.js render with Lenis
lenis.on("scroll", (e) => {
  // Update camera position, uniforms, etc.
});
```

## GSAP + ScrollTrigger (REQUIRED)

### ScrollTrigger Setup

```typescript
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

// ALWAYS use scrub for immersive effects
// scrub: 1 means it takes 1 second to catch up = buttery smooth
ScrollTrigger.create({
  trigger: ".section",
  start: "top bottom",
  end: "bottom top",
  scrub: 1,
  onUpdate: (self) => {
    // self.progress = 0 to 1
    updateScene(self.progress);
  },
});
```

### Three.js + ScrollTrigger Integration Pattern

```typescript
import * as THREE from "three";

// One master timeline for the whole 3D scene
const tl = gsap.timeline({
  scrollTrigger: {
    trigger: ".container",
    start: "top top",
    end: "bottom bottom",
    scrub: 1.5,       // ← higher scrub = smoother
    pin: ".container", // ← pins section while animating
    anticipatePin: 1,
  },
});

// Animate 3D object properties via GSAP
tl.to(car.position, { z: -5, duration: 1 }, 0)
  .to(car.rotation, { y: Math.PI * 2, duration: 2 }, 0)
  .to(camera.position, { z: 10, duration: 1 }, 1);
```

## Breakout Frame Effect ("Sale de la Pantalla")

The signature Japanese 3D effect. Objects appear to come OUT of the screen.

### Technique 1: CSS Clip-Path + Three.js

```css
.breakout-container {
  perspective: 1000px;
  overflow: visible !important;   /* ← KEY: let 3D overflow */
  clip-path: inset(0);            /* ← clip the container but not the 3D */
}

.breakout-three-canvas {
  position: fixed;                /* ← fixed = breaks out of flow */
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  pointer-events: none;
  z-index: 10;
}
```

### Technique 2: Three.js Depth Parallax

```typescript
// Each object at different Z depth moves at different speed
const layers = [
  { mesh: background, z: -20, speed: 0.1 },  // far = slow
  { mesh: midground,  z: -5,  speed: 0.3 },   // mid
  { mesh: foreground, z: 2,   speed: 0.8 },   // near = fast → "comes out"
  { mesh: hero,       z: 5,   speed: 1.2 },   // closest → breaks frame
];

lenis.on("scroll", (e) => {
  const scrollY = e.animatedScroll || e.targetScroll;
  layers.forEach(({ mesh, speed }) => {
    mesh.position.y = -scrollY * speed;
    // Objects with positive Z + fast speed appear to POP OUT
  });
});
```

## 3D Scene Setup Pattern

```typescript
import * as THREE from "three";

export function createScene(container: HTMLElement) {
  // Scene
  const scene = new THREE.Scene();
  scene.fog = new THREE.Fog(0x000000, 15, 30); // ← depth fog for realism

  // Camera — wider FOV = more dramatic perspective
  const camera = new THREE.PerspectiveCamera(
    45,                           // FOV: 45-60 for dramatic, 30-40 for cinematic
    window.innerWidth / window.innerHeight,
    0.1,
    100
  );
  camera.position.set(0, 0, 15);  // ← position Z = how far from scene

  // Renderer
  const renderer = new THREE.WebGLRenderer({
    antialias: true,
    alpha: true,                   // ← allows overlay on content
  });
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  container.appendChild(renderer.domElement);

  // Lights — CRITICAL for 3D depth perception
  const ambient = new THREE.AmbientLight(0xffffff, 0.5);
  scene.add(ambient);

  const dirLight = new THREE.DirectionalLight(0xffffff, 1);
  dirLight.position.set(5, 10, 7);
  scene.add(dirLight);

  // Animation loop via Lenis
  const clock = new THREE.Clock();
  lenis.on("scroll", () => {
    // Update scene based on scroll position
  });

  function animate() {
    requestAnimationFrame(animate);
    renderer.render(scene, camera);
  }
  animate();

  // Resize
  window.addEventListener("resize", () => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
  });

  return { scene, camera, renderer };
}
```

## Object Assembly Animation

For effects like the burger assembling itself or a car building up:

```typescript
gsap.registerPlugin(ScrollTrigger);

// Each part starts hidden, then appears in sequence
const parts = burgerParts.map((part, i) => {
  part.scale.set(0, 0, 0);
  part.position.y += i * 0.5;

  return gsap.to(part.scale, {
    x: 1, y: 1, z: 1,
    scrollTrigger: {
      trigger: ".burger-section",
      start: `top+=${i * 20}% top`,
      end: `top+=${(i + 1) * 20}% top`,
      scrub: 1,
    },
  });
});
```

## Integration with Astro (Islands Architecture)

For Astro projects, use the recommended pattern:

```astro
---
// src/pages/index.astro
---

<html>
  <head>
    <title>Immersive 3D Site</title>
  </head>
  <body>
    <!-- Static content renders on server -->
    <header>...</header>

    <!-- 3D scene loads as client island -->
    <ThreeScene client:visible />

    <section class="content">
      <h2>Scroll-triggered content</h2>
    </section>
  </body>
</html>
```

```typescript
// src/components/ThreeScene.tsx
// This becomes a client-side island with Three.js + GSAP + Lenis
import { useEffect, useRef } from "react";
import * as THREE from "three";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import Lenis from "lenis";

export default function ThreeScene() {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current) return;

    // Setup Lenis
    const lenis = new Lenis({ duration: 1.2 });
    requestAnimationFrame(function raf(t) {
      lenis.raf(t);
      requestAnimationFrame(raf);
    });

    // Setup Three.js
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.1, 100);
    camera.position.z = 15;

    const renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    containerRef.current.appendChild(renderer.domElement);

    // Add your 3D objects here...

    // GSAP ScrollTrigger for scroll-driven animation
    gsap.registerPlugin(ScrollTrigger);

    // Cleanup
    return () => {
      renderer.dispose();
      lenis.destroy();
      ScrollTrigger.getAll().forEach((st) => st.kill());
    };
  }, []);

  return <div ref={containerRef} style={{ position: "fixed", inset: 0, zIndex: 0, pointerEvents: "none" }} />;
}
```

## Three.js Model Loading with GLTF

```typescript
import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";
import { DRACOLoader } from "three/examples/jsm/loaders/DRACOLoader.js";

const loader = new GLTFLoader();
const draco = new DRACOLoader();
draco.setDecoderPath("https://www.gstatic.com/draco/versioned/decoders/1.5.6/");
loader.setDRACOLoader(draco);

loader.load("/models/car.glb", (gltf) => {
  const model = gltf.scene;
  scene.add(model);

  // Scale and position
  model.scale.set(0.5, 0.5, 0.5);
  model.position.set(0, -2, 0);

  // Animate with scroll
  ScrollTrigger.create({
    trigger: ".car-section",
    start: "top bottom",
    end: "bottom top",
    scrub: 1.5,
    onUpdate: (self) => {
      model.rotation.y = self.progress * Math.PI * 2;
      model.position.x = (self.progress - 0.5) * 10;
    },
  });
});
```

## Performance Rules (CRITICAL)

```typescript
// 1. ALWAYS cap pixel ratio
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

// 2. ALWAYS dispose on unmount
function cleanup() {
  renderer.dispose();
  scene.traverse((child) => {
    if (child instanceof THREE.Mesh) {
      child.geometry.dispose();
      if (Array.isArray(child.material)) {
        child.material.forEach((m) => m.dispose());
      } else {
        child.material.dispose();
      }
    }
  });
}

// 3. Use geometry merging for many objects
import { mergeGeometries } from "three/examples/jsm/utils/BufferGeometryUtils.js";

// 4. Reduce draw calls
// - Merge static geometry
// - Use instanced mesh for repeated objects
// - Use LOD (Level of Detail) for distant objects

// 5. Check device capability
const isMobile = /Mobi|Android/i.test(navigator.userAgent);
if (isMobile) {
  renderer.setPixelRatio(1);
  scene.fog = new THREE.Fog(0x000000, 30, 50); // hide distant objects
}
```

## Commands

```bash
# Install the stack
npm install three @types/three gsap lenis

# With React
npm install @react-three/fiber @react-three/drei @studio-freight/lenis

# GLTF/GLB model tools
npx gltfjsx model.glb  # Convert GLB to JSX component (R3F)
npx three@latest gltf-transform  # Optimize GLTF models

# Create a Vite project
npm create vite@latest . -- --template vanilla-ts
```

## Resources

- **Templates**: ready-to-use code templates in [assets/](assets/) — [`smooth-scroll-setup.md`](assets/smooth-scroll-setup.md), [`scroll-3d-animation.md`](assets/scroll-3d-animation.md), [`breakout-frame.md`](assets/breakout-frame.md), [`breakout-project.md`](assets/breakout-project.md) (code lives in fenced blocks per community policy)
- **Three.js Journey**: https://threejs-journey.com/ — BEST course (Bruno Simon)
- **GSAP ScrollTrigger**: https://gsap.com/docs/v3/Plugins/ScrollTrigger/
- **Lenis docs**: https://github.com/studio-freight/lenis
- **Spline**: https://spline.design — model 3D in browser
- **Inspiration**: https://www.awwwards.com/websites/three-js/
- **GLTF Transform**: https://gltf-transform.dev/ — optimize 3D models
