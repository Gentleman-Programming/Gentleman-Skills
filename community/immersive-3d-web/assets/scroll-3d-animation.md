# scroll-3d-animation.ts

```typescript
/**
 * scroll-3d-animation.ts
 *
 * Patrones de animación 3D con scroll usando GSAP ScrollTrigger + Three.js.
 * Cada función es un efecto independiente que podés copiar y pegar.
 *
 * REQUISITO: Lenis debe estar corriendo (ver smooth-scroll-setup.ts)
 */

import * as THREE from "three";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

// ============================================================
// 1. OBJETO QUE GIRA CON EL SCROLL (360º product viewer)
// ============================================================
export function spinOnScroll(
  mesh: THREE.Object3D,
  triggerSelector: string,
  options?: { totalRotations?: number; scrub?: number }
) {
  const rotations = options?.totalRotations ?? 2;

  return gsap.to(mesh.rotation, {
    y: Math.PI * 2 * rotations,
    scrollTrigger: {
      trigger: triggerSelector,
      start: "top bottom",
      end: "bottom top",
      scrub: options?.scrub ?? 1,
    },
  });
}

// ============================================================
// 2. OBJETO QUE SE ACERCA (breakout / sale de la pantalla)
// ============================================================
export function zoomInOnScroll(
  mesh: THREE.Object3D,
  triggerSelector: string,
  options?: {
    fromZ?: number;   // posición inicial Z
    toZ?: number;     // posición final Z (más positivo = más cerca = breakout)
    scrub?: number;
  }
) {
  const fromZ = options?.fromZ ?? 0;
  const toZ = options?.toZ ?? 5; // ← positivo = sale de pantalla

  mesh.position.z = fromZ;

  return gsap.to(mesh.position, {
    z: toZ,
    scrollTrigger: {
      trigger: triggerSelector,
      start: "top bottom",
      end: "top top",
      scrub: options?.scrub ?? 1.5,
    },
  });
}

// ============================================================
// 3. MONTAJE PROGRESIVO (hamburguesa armándose, auto ensamblándose)
// ============================================================
interface AssemblyPart {
  mesh: THREE.Object3D;
  startScale: number;  // 0 = invisible
  endScale: number;    // 1 = visible
  delay: number;       // 0 a 1, cuándo empieza relativo al scroll
}

export function assembleOnScroll(
  parts: AssemblyPart[],
  triggerSelector: string,
  options?: { scrub?: number }
) {
  return parts.map((part) => {
    part.mesh.scale.set(
      part.startScale,
      part.startScale,
      part.startScale
    );

    return gsap.to(part.mesh.scale, {
      x: part.endScale,
      y: part.endScale,
      z: part.endScale,
      scrollTrigger: {
        trigger: triggerSelector,
        start: `top+=${part.delay * 100}% bottom`,
        end: `top+=${(part.delay + 0.3) * 100}% bottom`,
        scrub: options?.scrub ?? 1,
      },
    });
  });
}

// EJEMPLO de uso para una hamburguesa:
// assembleOnScroll([
//   { mesh: bottomBun, startScale: 0, endScale: 1, delay: 0 },
//   { mesh: patty,     startScale: 0, endScale: 1, delay: 0.25 },
//   { mesh: lettuce,   startScale: 0, endScale: 1, delay: 0.5 },
//   { mesh: topBun,    startScale: 0, endScale: 1, delay: 0.75 },
// ], ".burger-section", { scrub: 1.5 });

// ============================================================
// 4. CÁMARA QUE SE MUEVE (efecto "voyage" / barco navegando)
// ============================================================
export function cameraTravel(
  camera: THREE.PerspectiveCamera,
  waypoints: Array<{ x: number; y: number; z: number }>,
  triggerSelector: string,
  options?: { scrub?: number }
) {
  // Creamos un objeto dummy para interpolar
  const dummy = new THREE.Object3D();
  dummy.position.copy(camera.position);

  const tl = gsap.timeline({
    scrollTrigger: {
      trigger: triggerSelector,
      start: "top bottom",
      end: "bottom top",
      scrub: options?.scrub ?? 2,
    },
  });

  waypoints.forEach((wp, i) => {
    tl.to(dummy.position, {
      x: wp.x,
      y: wp.y,
      z: wp.z,
      duration: 1,
      ease: "power2.inOut",
      onUpdate: () => camera.position.copy(dummy.position),
    }, i * 0.5);
  });

  return tl;
}

// ============================================================
// 5. FADE IN/FADE OUT con scroll (aparición/desaparición)
// ============================================================
export function fadeInOnScroll(
  mesh: THREE.Object3D,
  triggerSelector: string,
  options?: {
    fromOpacity?: number;
    toOpacity?: number;
    start?: string;
    end?: string;
    scrub?: number;
  }
) {
  if (!(mesh instanceof THREE.Mesh)) return;

  const material = (mesh as THREE.Mesh).material as THREE.Material;
  material.transparent = true;
  material.opacity = options?.fromOpacity ?? 0;

  return gsap.to(material, {
    opacity: options?.toOpacity ?? 1,
    scrollTrigger: {
      trigger: triggerSelector,
      start: options?.start ?? "top bottom",
      end: options?.end ?? "center center",
      scrub: options?.scrub ?? 1,
    },
  });
}

// ============================================================
// 6. PARTÍCULAS QUE REACCIONAN AL SCROLL
// ============================================================
export function particleScrollEffect(
  particles: THREE.Points,
  triggerSelector: string,
  options?: {
    spread?: number;     // qué tanto se dispersan
    speed?: number;      // velocidad del efecto
    scrub?: number;
  }
) {
  const positions = particles.geometry.attributes.position.array as Float32Array;
  const originalPositions = new Float32Array(positions);
  const spread = options?.spread ?? 5;

  return ScrollTrigger.create({
    trigger: triggerSelector,
    start: "top bottom",
    end: "bottom top",
    scrub: options?.scrub ?? 1.5,
    onUpdate: (self) => {
      const progress = self.progress;
      for (let i = 0; i < positions.length; i += 3) {
        // Dispersión radial desde el centro
        const dirX = originalPositions[i];
        const dirY = originalPositions[i + 1];
        const dirZ = originalPositions[i + 2];
        const dist = Math.sqrt(dirX * dirX + dirY * dirY + dirZ * dirZ) || 1;

        positions[i] = originalPositions[i] + (dirX / dist) * spread * progress;
        positions[i + 1] = originalPositions[i + 1] + (dirY / dist) * spread * progress;
        positions[i + 2] = originalPositions[i + 2] + (dirZ / dist) * spread * progress;
      }
      particles.geometry.attributes.position.needsUpdate = true;
    },
  });
}

// ============================================================
// 7. SCROLL PROGRESS -> UNIFORM (para shaders personalizados)
// ============================================================
export function bindScrollToUniform(
  material: THREE.ShaderMaterial | THREE.RawShaderMaterial,
  uniformName: string,
  triggerSelector: string,
  options?: {
    map?: (progress: number) => number;
    start?: string;
    end?: string;
    scrub?: number;
  }
) {
  const mapFn = options?.map ?? ((p: number) => p);

  return ScrollTrigger.create({
    trigger: triggerSelector,
    start: options?.start ?? "top bottom",
    end: options?.end ?? "bottom top",
    scrub: options?.scrub ?? 1,
    onUpdate: (self) => {
      if (material.uniforms[uniformName]) {
        material.uniforms[uniformName].value = mapFn(self.progress);
      }
    },
  });
}

// ============================================================
// 8. MULTI-OBJETO STAGGER (efecto cascada)
// ============================================================
export function staggerScrollAnimation(
  meshes: THREE.Object3D[],
  triggerSelector: string,
  options?: {
    property?: "position.y" | "position.x" | "rotation.x" | "rotation.y" | "scale";
    from?: number;
    to?: number;
    staggerAmount?: number; // delay entre cada objeto
    scrub?: number;
  }
) {
  const prop = options?.property ?? "position.y";
  const from = options?.from ?? -5;
  const to = options?.to ?? 0;

  return meshes.map((mesh, i) => {
    const vars: Record<string, unknown> = {};
    vars[prop] = to;
    vars.scrollTrigger = {
      trigger: triggerSelector,
      start: `top+=${(i / meshes.length) * 100}% bottom`,
      end: `top+=${((i + 1) / meshes.length) * 100}% bottom`,
      scrub: options?.scrub ?? 1.5,
    };

    // Set initial state
    const parts = prop.split(".");
    if (parts.length === 2) {
      (mesh as Record<string, unknown>)[parts[0]]![parts[1]] = from;
    } else if (parts.length === 1) {
      (mesh as Record<string, unknown>)[prop] = from;
    }

    return gsap.to(mesh, vars);
  });
}
```
