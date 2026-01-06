// Vercel serverless function for analyze-batch endpoint

// Engine constants
const PST = {
  p: [[0,0,0,0,0,0,0,0],[50,50,50,50,50,50,50,50],[10,10,20,30,30,20,10,10],[5,5,10,27,27,10,5,5],[0,0,0,25,25,0,0,0],[5,-5,-10,0,0,-10,-5,5],[5,10,10,-25,-25,10,10,5],[0,0,0,0,0,0,0,0]],
  n: [[-50,-40,-30,-30,-30,-30,-40,-50],[-40,-20,0,0,0,0,-20,-40],[-30,0,10,15,15,10,0,-30],[-30,5,15,20,20,15,5,-30],[-30,0,15,20,20,15,0,-30],[-30,5,10,15,15,10,5,-30],[-40,-20,0,5,5,0,-20,-40],[-50,-40,-30,-30,-30,-30,-40,-50]],
  b: [[-20,-10,-10,-10,-10,-10,-10,-20],[-10,0,0,0,0,0,0,-10],[-10,0,5,10,10,5,0,-10],[-10,5,5,10,10,5,5,-10],[-10,0,10,10,10,10,0,-10],[-10,10,10,10,10,10,10,-10],[-10,5,0,0,0,0,5,-10],[-20,-10,-10,-10,-10,-10,-10,-20]],
  r: [[0,0,0,0,0,0,0,0],[5,10,10,10,10,10,10,5],[-5,0,0,0,0,0,0,-5],[-5,0,0,0,0,0,0,-5],[-5,0,0,0,0,0,0,-5],[-5,0,0,0,0,0,0,-5],[-5,0,0,0,0,0,0,-5],[0,0,0,5,5,0,0,0]],
  q: [[-20,-10,-10,-5,-5,-10,-10,-20],[-10,0,0,0,0,0,0,-10],[-10,0,5,5,5,5,0,-10],[-5,0,5,5,5,5,0,-5],[0,0,5,5,5,5,0,-5],[-10,5,5,5,5,5,0,-10],[-10,0,5,0,0,0,0,-10],[-20,-10,-10,-5,-5,-10,-10,-20]],
  k: [[-30,-40,-40,-50,-50,-40,-40,-30],[-30,-40,-40,-50,-50,-40,-40,-30],[-30,-40,-40,-50,-50,-40,-40,-30],[-30,-40,-40,-50,-50,-40,-40,-30],[-20,-30,-30,-40,-40,-30,-30,-20],[-10,-20,-20,-20,-20,-20,-20,-10],[20,20,0,0,0,0,20,20],[20,30,10,0,0,10,30,20]]
};

const PV = { p:100, n:320, b:330, r:500, q:900, k:20000 };

class Engine {
  constructor() {
    this.b = [
      ['r','n','b','q','k','b','n','r'],
      ['p','p','p','p','p','p','p','p'],
      ['','','','','','','',''],
      ['','','','','','','',''],
      ['','','','','','','',''],
      ['','','','','','','',''],
      ['P','P','P','P','P','P','P','P'],
      ['R','N','B','Q','K','B','N','R']
    ];
    this.t = 'w';
    this.tt = new Map();
    this.km = Array(20).fill(0).map(() => [null, null]);
    this.hh = {};
  }

  m(mv) {
    const fc = mv.charCodeAt(0) - 97;
    const fr = 8 - parseInt(mv[1]);
    const tc = mv.charCodeAt(2) - 97;
    const tr = 8 - parseInt(mv[3]);
    if (fr<0||fr>7||tr<0||tr>7||fc<0||fc>7||tc<0||tc>7) return false;
    const p = this.b[fr][fc];
    if (!p) return false;
    this.b[tr][tc] = p;
    this.b[fr][fc] = '';
    this.t = this.t === 'w' ? 'b' : 'w';
    return true;
  }

  e() {
    let s = 0;
    for (let i=0;i<8;i++) for (let j=0;j<8;j++) {
      const p = this.b[i][j];
      if (!p) continue;
      const w = p === p.toUpperCase();
      const t = p.toLowerCase();
      const v = PV[t] || 0;
      const b = PST[t] ? PST[t][w ? i : 7-i][j] : 0;
      s += w ? (v+b) : -(v+b);
    }
    return s;
  }

  mvs() {
    const ms = [];
    for (let i=0;i<8;i++) for (let j=0;j<8;j++) {
      const p = this.b[i][j];
      if (!p) continue;
      const w = p === p.toUpperCase();
      if ((this.t==='w'&&!w)||(this.t==='b'&&w)) continue;
      const t = p.toLowerCase();
      const uci = (r1,c1,r2,c2) =>
        String.fromCharCode(97+c1)+(8-r1)+String.fromCharCode(97+c2)+(8-r2);

      if (t === 'p') {
        const d = w ? -1 : 1;
        const s = w ? 6 : 1;
        if (i+d>=0 && i+d<8 && !this.b[i+d][j]) {
          ms.push(uci(i,j,i+d,j));
          if (i===s && !this.b[i+2*d][j]) ms.push(uci(i,j,i+2*d,j));
        }
        for (const dc of [-1,1]) {
          if (j+dc>=0 && j+dc<8 && i+d>=0 && i+d<8) {
            const x = this.b[i+d][j+dc];
            if (x && (x===x.toUpperCase())!==w) ms.push(uci(i,j,i+d,j+dc));
          }
        }
      }
    }
    return ms;
  }
}

export default function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  );

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { moves } = req.body;
    if (!moves || !Array.isArray(moves)) {
      return res.status(400).json({ error: "moves array required" });
    }

    const engine = new Engine();
    const results = [];

    for (let i = 0; i < moves.length; i++) {
      const move = moves[i];
      engine.m(move);
      results.push({
        moveNumber: Math.floor(i/2)+1,
        played: move,
        eval: engine.e()
      });
    }

    res.status(200).json({ moves: results });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}
