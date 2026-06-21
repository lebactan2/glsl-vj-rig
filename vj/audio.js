// audio.js — Web Audio FFT -> smoothed bass/mid/treble/level + beat flag.
// Source can be the microphone or an <audio> file element.
export class AudioEngine {
  constructor() {
    this.ctx = null;
    this.analyser = null;
    this.bins = null;
    this.audioEl = null;
    this.source = null;
    // smoothed bands (0..1)
    this.bass = 0; this.mid = 0; this.treble = 0; this.level = 0;
    this.beat = 0;            // decays each frame, spikes to 1 on a kick
    this._bassAvg = 0;        // running average for adaptive beat threshold
    this.ready = false;
  }

  _setup(node) {
    if (!this.ctx) this.ctx = new (window.AudioContext || window.webkitAudioContext)();
    if (this.analyser) { try { this.source && this.source.disconnect(); } catch (e) {} }
    this.analyser = this.ctx.createAnalyser();
    this.analyser.fftSize = 1024;
    this.analyser.smoothingTimeConstant = 0.8;
    this.bins = new Uint8Array(this.analyser.frequencyBinCount);
    this.source = node;
    node.connect(this.analyser);
    this.ready = true;
  }

  async useMic() {
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    if (!this.ctx) this.ctx = new (window.AudioContext || window.webkitAudioContext)();
    await this.ctx.resume();
    this._setup(this.ctx.createMediaStreamSource(stream));
    return "mic";
  }

  async useFile(file) {
    if (!this.ctx) this.ctx = new (window.AudioContext || window.webkitAudioContext)();
    await this.ctx.resume();
    if (!this.audioEl) {
      this.audioEl = new Audio();
      this.audioEl.loop = true;
      this._mediaNode = this.ctx.createMediaElementSource(this.audioEl);
      this._mediaNode.connect(this.ctx.destination); // so you can hear it
    }
    this.audioEl.src = URL.createObjectURL(file);
    this._setup(this._mediaNode);
    await this.audioEl.play();
    return file.name;
  }

  playPause() {
    if (this.audioEl) (this.audioEl.paused ? this.audioEl.play() : this.audioEl.pause());
  }

  // call once per frame
  update() {
    if (!this.ready) return this;
    this.analyser.getByteFrequencyData(this.bins);
    const N = this.bins.length;
    const band = (a, b) => {
      a = Math.max(0, a | 0); b = Math.min(N, b | 0);
      let s = 0; for (let i = a; i < b; i++) s += this.bins[i];
      return (b > a) ? s / ((b - a) * 255) : 0;
    };
    const k = 0.3;
    this.bass   += (band(1, 8)    - this.bass)   * k;
    this.mid    += (band(8, 40)   - this.mid)    * k;
    this.treble += (band(40, 128) - this.treble) * k;
    this.level  += (band(1, 128)  - this.level)  * 0.2;

    // adaptive beat detection on bass
    this._bassAvg += (this.bass - this._bassAvg) * 0.05;
    if (this.bass > this._bassAvg * 1.35 && this.bass > 0.12) this.beat = 1.0;
    else this.beat *= 0.85; // decay
    return this;
  }
}
