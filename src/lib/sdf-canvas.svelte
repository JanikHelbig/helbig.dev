<script lang="ts">
  import { devicePixelRatio } from "svelte/reactivity/window";
  import type { Attachment } from "svelte/attachments";
  import vert from "/src/shader/vert.glsl?raw";
  import frag from "/src/shader/frag.glsl?raw";

  let { width = '100%', height = '100%', ...props } = $props();

  let canvasWidth = $state(0);
  let canvasHeight = $state(0);
  let mousePosition = $state({ x: -100, y: -100 });

  function handleMouseMove(event: MouseEvent) {
      mousePosition.x = event.offsetX;
      mousePosition.y = event.offsetY;
  }

  function handleMouseLeave(event: MouseEvent) {
      mousePosition.x = -100;
      mousePosition.y = -100;
  }

  const canvasAttachment: Attachment<HTMLCanvasElement> = (canvas) => {
    const gl: WebGL2RenderingContext = canvas.getContext("webgl2", {
      alpha: true,
      desynchronized: true,
      powerPreference: "high-performance",
      preserveDrawingBuffer: false,
      antialias: false,
    })!;

    const program = createProgram(gl, vert, frag);

    const viewportRectLoc = gl.getUniformLocation(program, "viewportRect");
    const timeLoc = gl.getUniformLocation(program, "time");
    const mousePositionLoc = gl.getUniformLocation(program, "mousePosition");

    gl.useProgram(program);

    function render(timestamp: DOMHighResTimeStamp) {
      updateCanvas(timestamp);
      requestAnimationFrame(render);
    }

    function updateCanvas(time: DOMHighResTimeStamp) {
      const ratio = devicePixelRatio.current ?? 1;

      gl.viewport(0, 0, canvasWidth * ratio, canvasHeight * ratio);
      gl.uniform4f(viewportRectLoc, 0, 0, canvasWidth, canvasHeight);
      gl.uniform1f(timeLoc, time * 0.001);
      gl.uniform2f(mousePositionLoc, mousePosition.x, mousePosition.y);

      gl.drawArrays(gl.TRIANGLE_FAN, 0, 3);
      gl.flush();
    }

    requestAnimationFrame(render);

    $effect(() => {
      const ratio = devicePixelRatio.current ?? 1;
      canvas.width = canvasWidth * ratio;
      canvas.height = canvasHeight * ratio;
    });
  };

  function createProgram(gl: WebGL2RenderingContext, vert: string, frag: string): WebGLProgram {
      const program = gl.createProgram();
      gl.attachShader(program, createShader(gl, vert, gl.VERTEX_SHADER));
      gl.attachShader(program, createShader(gl, frag, gl.FRAGMENT_SHADER));
      gl.linkProgram(program);
      if (!gl.getProgramParameter(program, gl.LINK_STATUS))
          throw new Error(gl.getProgramInfoLog(program) ?? "Program link failed.");
      return program;
  }

  function createShader(gl: WebGL2RenderingContext, source: string, type: number) {
      const shader: WebGLShader = gl.createShader(type)!;
      gl.shaderSource(shader, source);
      gl.compileShader(shader);
      if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS))
          throw new Error(gl.getShaderInfoLog(shader) ?? "Shader compilation failed.");
      return shader;
  }
</script>

<canvas onmousemove={handleMouseMove} onmouseleave={handleMouseLeave} style="--canvas-width: {width}; --canvas-height: {height};" bind:clientWidth={canvasWidth} bind:clientHeight={canvasHeight} {@attach canvasAttachment}></canvas>

<style>
    canvas {
        display: block;
        width: var(--canvas-width);
        height: var(--canvas-height);
    }
</style>
