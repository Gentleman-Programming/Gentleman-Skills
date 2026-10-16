# smooth-scroll-setup.ts

```typescript
/**
 * smooth-scroll-setup.ts
 *
 * SETUP MÍNIMO para empezar cualquier proyecto 3D inmersivo.
 * Copiá este archivo a tu proyecto y ajustá lo necesario.
 *
 * Incluye:
 * - Lenis smooth scroll
 * - Three.js scene básica
 * - GSAP ScrollTrigger
 * - Parallax 3D listo para usar
 * - Breakout frame effect
 */

import * as THREE from "three";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import Lenis from "lenis";

gsap.registerPlugin(ScrollTrigger);

// ============================================================
// 1. CONFIG — Ajustá acá los parámetros
// ============================================================
const CONFIG = {
  // Lenis
  smoothDuration: 1.2,
  smoothEasing: (t: number) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),

  // Three.js
  cameraFov: 50,
  cameraZ: 15,
  bgColor: 0x0a0a0a,
  fogNear: 15,
  fogFar: 30,

  // Parallax — qué tanto se mueve cada capa (más alto = más rápido = más breakout)
  parallaxSpeed: {
    background: 0.05,
    midground: 0.1,
    foreground: 0.2,
    breakout: 0.35, // ← objetos "breakout" se mueven más rápido
  },

  // Performance
  maxPixelRatio: 2,
};

// ============================================================
// 2. LENIS
// ============================================================
export function createSmoothScroll() {
  const lenis = new Lenis({
    duration: CONFIG.smoothDuration,
    easing: CONFIG.smoothEasing,
    orientation: "vertical",
    smoothWheel: true,
  });

  function raf(time: number) {
    lenis.raf(time);
    requestAnimationFrame(raf);
  }
  requestAnimationFrame(raf);

  return lenis;
}

// ============================================================
// 3. THREE.JS SCENE
// ============================================================
export interface Scene3D {
  scene: THREE.Scene;
  camera: THREE.PerspectiveCamera;
  renderer: THREE.WebGLRenderer;
  cleanup: () => void;
}

export function createScene(container: HTMLElement): Scene3D {
  const scene = new THREE.Scene();
  scene.background = new THREE.Color(CONFIG.bgColor);
  scene.fog = new THREE.Fog(CONFIG.bgColor, CONFIG.fogNear, CONFIG.fogFar);

  const camera = new THREE.PerspectiveCamera(
    CONFIG.cameraFov,
    container.clientWidth / container.clientHeight,
    0.1,
    100
  );
  camera.position.set(0, 0, CONFIG.cameraZ);

  const renderer = new THREE.WebGLRenderer({
    antialias: true,
    alpha: true,
  });
  renderer.setSize(container.clientWidth, container.clientHeight);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, CONFIG.maxPixelRatio));
  renderer.toneMapping = THREE.ACESFilmicToneMapping;
  renderer.toneMappingExposure = 1.5;
  container.appendChild(renderer.domElement);

  // Lights
  const ambient = new THREE.AmbientLight(0x404060, 0.5);
  scene.add(ambient);

  const dirLight = new THREE.DirectionalLight(0xffffff, 1.5);
  dirLight.position.set(5, 10, 7);
  scene.add(dirLight);

  const backLight = new THREE.DirectionalLight(0x4466ff, 0.5);
  backLight.position.set(-5, 0, -5);
  scene.add(backLight);

  // Resize
  const onResize = () => {
    camera.aspect = container.clientWidth / container.clientHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(container.clientWidth, container.clientHeight);
  };
  window.addEventListener("resize", onResize);

  return {
    scene,
    camera,
    renderer,
    cleanup: () => {
      window.removeEventListener("resize", onResize);
      renderer.dispose();
    },
  };
}

// ============================================================
// 4. PARALLAX LAYER
// ============================================================
export interface ParallaxLayer {
  mesh: THREE.Object3D;
  speed: number;
  baseZ: number;
  baseY: number;
}

/**
 * Creá capas de parallax y pasalas a updateParallax() en el scroll.
 *
 * EJEMPLO:
 * const layers = [
 *   { mesh: bgMesh,  speed: 0.05, baseZ: -15, baseY: 0 },
 *   { mesh: heroMesh, speed: 0.35, baseZ: 3, baseY: 0 },  // breakout!
 * ];
 */
export function updateParallax(
  layers: ParallaxLayer[],
  scrollY: number
) {
  layers.forEach(({ mesh, speed, baseZ, baseY }) => {
    mesh.position.y = baseY - scrollY * speed;
    // No tocamos Z acá — la profundidad se maneja con baseZ
  });
}

// ============================================================
// 5. SCROLLTRIGGER HELPER
// ============================================================
export function createScrollAnimation(
  triggerSelector: string,
  onProgress: (progress: number) => void,
  options?: {
    scrub?: number;
    start?: string;
    end?: string;
  }
) {
  return ScrollTrigger.create({
    trigger: triggerSelector,
    start: options?.start ?? "top bottom",
    end: options?.end ?? "bottom top",
    scrub: options?.scrub ?? 1.5,
    onUpdate: (self) => onProgress(self.progress),
  });
}

// ============================================================
// 6. FULL SETUP — Todo junto
// ============================================================
export function setupImmersiveScene(containerId: string) {
  const container = document.getElementById(containerId);
  if (!container) throw new Error(`Container #${containerId} not found`);

  const lenis = createSmoothScroll();
  const { scene, camera, renderer } = createScene(container);

  const layers: ParallaxLayer[] = [];
  const scrollData = { y: 0, progress: 0 };

  // Conectá Lenis + actualización de capas
  lenis.on("scroll", (e) => {
    scrollData.y = e.animatedScroll || e.targetScroll || 0;
    updateParallax(layers, scrollData.y);
  });

  // Animation loop
  function animate() {
    requestAnimationFrame(animate);
    renderer.render(scene, camera);
  }
  animate();

  return {
    scene,
    camera,
    renderer,
    lenis,
    layers,
    scrollData,
    addLayer: (layer: ParallaxLayer) => layers.push(layer),
    cleanup: () => {
      lenis.destroy();
      renderer.dispose();
      ScrollTrigger.getAll().forEach((st) => st.kill());
    },
  };
}
```
