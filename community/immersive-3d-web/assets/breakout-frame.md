# breakout-frame.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Breakout Frame Effect — Immersive 3D</title>
  <style>
    /* === RESET === */
    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: system-ui, sans-serif;
      background: #0a0a0a;
      color: white;
      overflow-x: hidden;
    }

    /* === SMOOTH SCROLL via Lenis === */
    html.lenis { height: auto; }
    .lenis-smooth { scroll-behavior: auto; }
    .lenis-smooth [data-lenis-prevent] { overscroll-behavior: contain; }

    /* === SECTIONS === */
    section {
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 4rem 2rem;
      position: relative;
      z-index: 1;
    }

    .section-spacer { min-height: 50vh; }

    h1 {
      font-size: clamp(2rem, 5vw, 4rem);
      text-align: center;
      max-width: 800px;
      line-height: 1.2;
    }

    p {
      font-size: clamp(1rem, 2vw, 1.25rem);
      max-width: 600px;
      text-align: center;
      margin-top: 1rem;
      opacity: 0.7;
      line-height: 1.6;
    }

    /* === BREAKOUT CANVAS — el canvas 3D flota sobre TODO === */
    #three-canvas {
      position: fixed;
      top: 0;
      left: 0;
      width: 100vw;
      height: 100vh;
      z-index: 0;
      pointer-events: none;  /* ← permite interactuar con el contenido detrás */
    }

    /* === CONTENIDO POR ENCIMA DEL 3D === */
    .content {
      position: relative;
      z-index: 1;
    }

    /* === CARDS DE EJEMPLO === */
    .card-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 2rem;
      max-width: 1000px;
      width: 100%;
      margin-top: 3rem;
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
    }

    .card p {
      font-size: 0.95rem;
      text-align: left;
      margin-top: 0;
      opacity: 0.6;
    }
  </style>
</head>
<body>
  <!-- Canvas 3D — fixed, pointer-events none, z-index 0 -->
  <div id="three-canvas"></div>

  <!-- Contenido con scroll -->
  <main class="content">

    <!-- HERO -->
    <section>
      <h1>🚗 3D Breakout Frame</h1>
      <p>Objetos que SALEN de la pantalla. Parallax 3D con Three.js + GSAP + Lenis.</p>
      <p style="font-size: 0.85rem; opacity: 0.4; margin-top: 2rem;">
        Scrollea para ver el efecto
      </p>
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

    <!-- TECH -->
    <section>
      <h2>Stack Completo</h2>
      <div class="card-grid">
        <div class="card">
          <h3>Three.js</h3>
          <p>WebGL scene + camera perspective + fog for depth</p>
        </div>
        <div class="card">
          <h3>GSAP</h3>
          <p>ScrollTrigger + timelines for scroll-animated 3D</p>
        </div>
        <div class="card">
          <h3>Lenis</h3>
          <p>Physics-based smooth scrolling at 60fps</p>
        </div>
      </div>
    </section>

    <section class="section-spacer"></section>

    <!-- FOOTER -->
    <section>
      <h2>¿Listo para crear?</h2>
      <p>Cloneá este template y empezá a experimentar.</p>
      <p style="font-size: 0.85rem; margin-top: 2rem; opacity: 0.4;">
        Creado con 🎩 Gentleman Programming — Skill immersive-3d-web
      </p>
    </section>

    <section style="min-height: 30vh;"></section>

  </main>

  <!-- ============================================ -->
  <!-- THREE.JS + GSAP + LENIS — CÓDIGO PRINCIPAL   -->
  <!-- ============================================ -->

  <!-- ⚠️ IMPORTANTE: Este HTML necesita un servidor HTTP para funcionar.
       No lo abras directo con doble-click (file://), no funciona.
       
       Opción 1: npx serve .
       Opción 2: python3 -m http.server
       Opción 3: Usá el proyecto Vite en assets/breakout-project/ (npm run dev)

       Si ves esta página sin el canvas 3D, abrí la consola (F12) para ver errores.
  -->

  <!-- Error handler visible — si algo falla, se ve en pantalla -->
  <script>
    window.addEventListener("error", (e) => {
      const div = document.createElement("div");
      div.style.cssText = "position:fixed;top:0;left:0;right:0;background:#ff0044;color:white;padding:1rem;font-family:monospace;z-index:9999;font-size:0.9rem;";
      div.textContent = `🔥 ERROR: ${e.message || e}`;
      document.body.prepend(div);
      console.error("🔥 3D Error:", e);
    });
    window.addEventListener("unhandledrejection", (e) => {
      const div = document.createElement("div");
      div.style.cssText = "position:fixed;top:0;left:0;right:0;background:#ff0044;color:white;padding:1rem;font-family:monospace;z-index:9999;font-size:0.9rem;";
      div.textContent = `🔥 ERROR: ${e.reason?.message || e.reason}`;
      document.body.prepend(div);
      console.error("🔥 3D Error:", e);
    });
  </script>

  <script type="importmap">
  {
    "imports": {
      "three": "https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.module.js",
      "three/addons/": "https://cdn.jsdelivr.net/npm/three@0.160.0/examples/jsm/",
      "gsap": "https://cdn.jsdelivr.net/npm/gsap@3.12.5/+esm",
      "gsap/ScrollTrigger": "https://cdn.jsdelivr.net/npm/gsap@3.12.5/ScrollTrigger.js",
      "lenis": "https://cdn.jsdelivr.net/npm/lenis@1.1.13/dist/lenis.mjs"
    }
  }
  </script>

  <script type="module">
    import * as THREE from "three";
    import { gsap } from "gsap";
    import { ScrollTrigger } from "gsap/ScrollTrigger";
    import Lenis from "lenis";

    gsap.registerPlugin(ScrollTrigger);

    // =====================
    // 1. LENIS — Smooth Scroll
    // =====================
    const lenis = new Lenis({
      duration: 1.2,
      easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
      orientation: "vertical",
      smoothWheel: true,
    });

    function raf(time) {
      lenis.raf(time);
      requestAnimationFrame(raf);
    }
    requestAnimationFrame(raf);

    // =====================
    // 2. THREE.JS — 3D Scene
    // =====================
    const container = document.getElementById("three-canvas");
    const scene = new THREE.Scene();

    // Camera — perspective agresiva para dramatismo
    const camera = new THREE.PerspectiveCamera(
      50, // FOV: más alto = más profundidad dramática
      window.innerWidth / window.innerHeight,
      0.1,
      100
    );
    camera.position.set(0, 0, 15);

    // Renderer — alfa: true para ver el contenido detrás
    const renderer = new THREE.WebGLRenderer({
      antialias: true,
      alpha: true,
    });
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.5;
    container.appendChild(renderer.domElement);

    // =====================
    // 3. LIGHTS
    // =====================
    const ambientLight = new THREE.AmbientLight(0x404060, 0.5);
    scene.add(ambientLight);

    const directionalLight = new THREE.DirectionalLight(0xffffff, 1.5);
    directionalLight.position.set(5, 10, 7);
    scene.add(directionalLight);

    const backLight = new THREE.DirectionalLight(0x4466ff, 0.8);
    backLight.position.set(-5, 0, -5);
    scene.add(backLight);

    // =====================
    // 4. 3D OBJECTS — Capas de Parallax
    // =====================

    // --- CAPA 1: Fondo (lento, lejano) ---
    const bgGeo = new THREE.IcosahedronGeometry(4, 1);
    const bgMat = new THREE.MeshStandardMaterial({
      color: 0x2233aa,
      wireframe: true,
      transparent: true,
      opacity: 0.15,
    });
    const bgMesh = new THREE.Mesh(bgGeo, bgMat);
    bgMesh.position.z = -15;
    scene.add(bgMesh);

    // --- CAPA 2: Anillos flotantes (mid) ---
    const rings = [];
    for (let i = 0; i < 8; i++) {
      const geo = new THREE.TorusGeometry(1 + i * 0.4, 0.05, 16, 32);
      const mat = new THREE.MeshStandardMaterial({
        color: new THREE.Color().setHSL(i * 0.12, 0.8, 0.6),
        transparent: true,
        opacity: 0.3 + i * 0.05,
      });
      const mesh = new THREE.Mesh(geo, mat);
      mesh.position.set(
        Math.cos(i * 0.8) * 6,
        Math.sin(i * 0.8) * 6 - 2,
        -5 + i * 0.3
      );
      mesh.rotation.x = Math.PI * 0.3;
      mesh.rotation.z = i * 0.5;
      scene.add(mesh);
      rings.push(mesh);
    }

    // --- CAPA 3: Cubo central (foreground — efecto breakout) ---
    const boxGeo = new THREE.BoxGeometry(1.5, 1.5, 1.5);
    const boxMat = new THREE.MeshStandardMaterial({
      color: 0xff4477,
      metalness: 0.8,
      roughness: 0.2,
      emissive: 0xff2244,
      emissiveIntensity: 0.2,
    });
    const box = new THREE.Mesh(boxGeo, boxMat);
    box.position.set(0, 0, 3);  // ← Z positivo = parece salir de la pantalla
    scene.add(box);

    // Pequeños satélites alrededor del cubo
    const satellites = [];
    for (let i = 0; i < 6; i++) {
      const geo = new THREE.SphereGeometry(0.15, 8, 8);
      const mat = new THREE.MeshStandardMaterial({
        color: 0x66ddff,
        emissive: 0x4488ff,
        emissiveIntensity: 0.5,
      });
      const mesh = new THREE.Mesh(geo, mat);
      mesh.userData.angle = (i / 6) * Math.PI * 2;
      mesh.userData.radius = 2;
      mesh.position.z = 3;
      scene.add(mesh);
      satellites.push(mesh);
    }

    // --- CAPA 4: Partículas flotantes (más cerca = más velocidad) ---
    const particleCount = 300;
    const particleGeo = new THREE.BufferGeometry();
    const positions = new Float32Array(particleCount * 3);
    for (let i = 0; i < particleCount * 3; i++) {
      positions[i] = (Math.random() - 0.5) * 30;
    }
    particleGeo.setAttribute("position", new THREE.BufferAttribute(positions, 3));
    const particleMat = new THREE.PointsMaterial({
      color: 0x88aaff,
      size: 0.08,
      transparent: true,
      opacity: 0.6,
      sizeAttenuation: true,
    });
    const particles = new THREE.Points(particleGeo, particleMat);
    particles.position.z = 3;
    scene.add(particles);

    // =====================
    // 5. SCROLLTRIGGER — Animación 3D con scroll
    // =====================
    const scrollData = { progress: 0, y: 0 };

    // Timeline principal
    const tl = gsap.timeline({
      scrollTrigger: {
        trigger: "body",
        start: "top top",
        end: "bottom bottom",
        scrub: 1.5,
        onUpdate: (self) => {
          scrollData.progress = self.progress;
        },
      },
    });

    // Animación del cubo breakout: rota y se acerca
    tl.to(box.position, { z: 6, duration: 1 }, 0)
      .to(box.rotation, { y: Math.PI * 4, x: Math.PI * 2, duration: 2 }, 0)
      .to(box.scale, { x: 1.5, y: 1.5, z: 1.5, duration: 1.5 }, 0.5);

    // =====================
    // 6. LENIS + SCROLL — Parallax manual
    // =====================
    lenis.on("scroll", (e) => {
      const y = e.animatedScroll || e.targetScroll || 0;
      scrollData.y = y;

      // Capa 1: fondo — muy lento
      bgMesh.position.y = -y * 0.05;
      bgMesh.rotation.y = y * 0.002;

      // Capa 2: anillos — velocidad media
      rings.forEach((ring, i) => {
        ring.position.y = -y * 0.1 + Math.sin(i + y * 0.001) * 2;
        ring.rotation.x += 0.005;
        ring.rotation.z += 0.003;
      });

      // Capa 3: cubo breakout — velocidad ALTA
      box.position.y = -y * 0.2;

      // Satélites orbitan
      satellites.forEach((sat, i) => {
        const angle = sat.userData.angle + y * 0.003;
        sat.position.x = Math.cos(angle) * sat.userData.radius;
        sat.position.y = Math.sin(angle) * sat.userData.radius - y * 0.2;
      });

      // Capa 4: partículas — velocidad MUY ALTA (breakout total)
      particles.position.y = -y * 0.3;
    });

    // =====================
    // 7. ANIMATION LOOP
    // =====================
    function animate() {
      requestAnimationFrame(animate);

      // Auto-rotation suave de los anillos
      rings.forEach((ring, i) => {
        ring.rotation.y += 0.003 * (1 + i * 0.2);
      });

      // Cubo pulsa suavemente
      const pulse = 1 + Math.sin(Date.now() * 0.002) * 0.05;
      box.scale.x = pulse;
      box.scale.y = pulse;
      box.scale.z = pulse;

      renderer.render(scene, camera);
    }
    animate();

    // =====================
    // 8. RESIZE
    // =====================
    window.addEventListener("resize", () => {
      camera.aspect = window.innerWidth / window.innerHeight;
      camera.updateProjectionMatrix();
      renderer.setSize(window.innerWidth, window.innerHeight);
    });

    console.log("🚀 Breakout Frame 3D — inician scrolleando!");
  </script>
</body>
</html>
```
