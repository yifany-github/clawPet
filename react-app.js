import React, { useState, useEffect, useRef } from 'react';

const customStyles = {
  plasticBody: {
    background: 'radial-gradient(circle at 30% 30%, #4ade80 0%, #22c55e 50%, #16a34a 100%)',
    boxShadow: 'inset -10px -10px 20px rgba(0,0,0,0.2), inset 10px 10px 20px rgba(255,255,255,0.4), 15px 15px 35px rgba(0,0,0,0.3)',
  },
  plasticButton: {
    boxShadow: 'inset 2px 2px 5px rgba(255,255,255,0.4), inset -2px -2px 5px rgba(0,0,0,0.2), 2px 2px 5px rgba(0,0,0,0.3)',
  },
  lcdBg: {
    backgroundColor: '#9ea786',
    backgroundImage: 'linear-gradient(rgba(0, 0, 0, 0.05) 1px, transparent 1px), linear-gradient(90deg, rgba(0, 0, 0, 0.05) 1px, transparent 1px)',
    backgroundSize: '4px 4px',
  },
  glareRadial: {
    background: 'radial-gradient(circle at 30% 30%, rgba(255,255,255,0.1) 0%, transparent 60%)',
  },
};

const App = () => {
  const [gearRotation, setGearRotation] = useState(-15);
  const [isHoveringGear, setIsHoveringGear] = useState(false);
  const isHoveringRef = useRef(false);
  const gearRotationRef = useRef(-15);

  useEffect(() => {
    const style = document.createElement('style');
    style.textContent = `
      @import url('https://fonts.googleapis.com/css2?family=VT323&display=swap');

      .pixel-font {
        font-family: 'VT323', monospace;
        text-shadow: 1px 1px 0px rgba(0,0,0,0.1);
      }

      .scanlines::before {
        content: " ";
        display: block;
        position: absolute;
        top: 0;
        left: 0;
        bottom: 0;
        right: 0;
        background: linear-gradient(rgba(18, 16, 16, 0) 50%, rgba(0, 0, 0, 0.1) 50%);
        z-index: 20;
        background-size: 100% 4px;
        pointer-events: none;
        border-radius: 50%;
      }

      .glare::after {
        content: '';
        position: absolute;
        top: 5%;
        left: 5%;
        width: 90%;
        height: 45%;
        background: linear-gradient(to bottom, rgba(255,255,255,0.15), transparent);
        border-radius: 50% 50% 10% 10%;
        pointer-events: none;
        z-index: 30;
      }

      @keyframes squish {
        0%, 100% { transform: scale(1, 1) translateY(0); }
        50% { transform: scale(1.1, 0.8) translateY(4px); }
      }

      @keyframes float {
        0%, 100% { transform: translateY(0px); }
        50% { transform: translateY(-8px); }
      }

      .pet-animate {
        animation: float 2s ease-in-out infinite, squish 2s ease-in-out infinite;
      }
    `;
    document.head.appendChild(style);
    return () => document.head.removeChild(style);
  }, []);

  useEffect(() => {
    const handleWheel = (e) => {
      if (isHoveringRef.current) {
        e.preventDefault();
        gearRotationRef.current += e.deltaY * 0.4;
        setGearRotation(gearRotationRef.current);
      }
    };
    window.addEventListener('wheel', handleWheel, { passive: false });
    return () => window.removeEventListener('wheel', handleWheel);
  }, []);

  const handleGearEnter = () => {
    isHoveringRef.current = true;
    setIsHoveringGear(true);
  };

  const handleGearLeave = () => {
    isHoveringRef.current = false;
    setIsHoveringGear(false);
  };

  return (
    <div className="w-full h-screen bg-slate-100 flex items-center justify-center overflow-hidden select-none">
      {/* Shadow */}
      <div
        className="absolute w-[280px] h-[28px] bg-black/20 blur-xl rounded-full"
        style={{ transform: 'translateY(160px) translateX(10px)' }}
      />

      {/* Main container */}
      <div className="relative">

        {/* Left side button */}
        <button
          className="absolute top-14 -left-4 w-6 h-16 bg-yellow-400 rounded-l-lg border-y-2 border-l-2 border-yellow-600 z-0 active:translate-x-1 transition-transform duration-75 group"
          style={customStyles.plasticButton}
        >
          <div className="w-full h-full flex items-center justify-center opacity-0 group-active:opacity-100 transition-opacity">
            <div className="w-1 h-8 bg-black/10 rounded-full" />
          </div>
        </button>

        {/* Top button */}
        <button
          className="absolute -top-4 left-16 w-16 h-6 bg-yellow-400 rounded-t-lg border-x-2 border-t-2 border-yellow-600 z-0 active:translate-y-1 transition-transform duration-75 group"
          style={customStyles.plasticButton}
        >
          <div className="w-full h-full flex items-center justify-center opacity-0 group-active:opacity-100 transition-opacity">
            <div className="w-8 h-1 bg-black/10 rounded-full" />
          </div>
        </button>

        {/* Gear */}
        <div
          id="gear-container"
          className="absolute top-8 -right-14 w-40 h-40 z-0 active:scale-[0.95] transition-transform duration-75 cursor-pointer"
          onMouseEnter={handleGearEnter}
          onMouseLeave={handleGearLeave}
        >
          <div className="relative w-full h-full flex items-center justify-center">
            <svg
              viewBox="0 0 80 80"
              className="w-full h-full"
              style={{ filter: 'drop-shadow(2px 2px 4px rgba(0,0,0,0.4))' }}
            >
              <defs>
                <linearGradient id="gearGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" style={{ stopColor: '#5a5a5a' }} />
                  <stop offset="50%" style={{ stopColor: '#2a2a2a' }} />
                  <stop offset="100%" style={{ stopColor: '#1a1a1a' }} />
                </linearGradient>
                <linearGradient id="toothGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" style={{ stopColor: '#6a6a6a' }} />
                  <stop offset="50%" style={{ stopColor: '#3a3a3a' }} />
                  <stop offset="100%" style={{ stopColor: '#1a1a1a' }} />
                </linearGradient>
              </defs>
              <g
                id="gear-rotator"
                transform={`translate(40,40) rotate(${gearRotation})`}
                className="transition-transform duration-75 cursor-pointer"
              >
                <g>
                  <circle cx="0" cy="0" r="18" fill="url(#gearGradient)" stroke="#1a1a1a" strokeWidth="1" />
                  <circle cx="0" cy="0" r="12" fill="#2a2a2a" stroke="#1a1a1a" strokeWidth="1" />
                  <circle cx="0" cy="0" r="6" fill="#1a1a1a" />
                  <rect x="-2" y="-14" width="4" height="8" rx="0.5" fill="url(#toothGradient)" />
                  <rect x="-2" y="-14" width="4" height="8" rx="0.5" transform="rotate(45)" fill="url(#toothGradient)" />
                  <rect x="-2" y="-14" width="4" height="8" rx="0.5" transform="rotate(90)" fill="url(#toothGradient)" />
                  <rect x="-2" y="-14" width="4" height="8" rx="0.5" transform="rotate(135)" fill="url(#toothGradient)" />
                  <rect x="-2" y="-14" width="4" height="8" rx="0.5" transform="rotate(180)" fill="url(#toothGradient)" />
                  <rect x="-2" y="-14" width="4" height="8" rx="0.5" transform="rotate(225)" fill="url(#toothGradient)" />
                  <rect x="-2" y="-14" width="4" height="8" rx="0.5" transform="rotate(270)" fill="url(#toothGradient)" />
                  <rect x="-2" y="-14" width="4" height="8" rx="0.5" transform="rotate(315)" fill="url(#toothGradient)" />
                </g>
              </g>
            </svg>
            <div className="absolute inset-0 rounded-full" style={customStyles.glareRadial} />
          </div>
        </div>

        {/* Main body */}
        <div
          className="relative w-[320px] h-[320px] rounded-[50%] rounded-tl-[56px] border-[3px] border-green-700 flex items-center justify-center z-10"
          style={customStyles.plasticBody}
        >
          {/* Small screen top-left */}
          <div className="absolute top-6 left-6 w-12 h-12 bg-zinc-800 rounded-full border-[3px] border-zinc-900 flex items-center justify-center p-1"
            style={{ boxShadow: 'inset 0 4px 8px rgba(0,0,0,0.8), 0 2px 4px rgba(0,0,0,0.2)' }}
          >
            <div className="w-full h-full bg-[#9ea786] rounded-full flex items-center justify-center overflow-hidden">
              <div className="w-full h-full relative overflow-hidden">
                <div className="w-full h-full flex items-center justify-center text-4xl">😊</div>
                <div
                  className="absolute inset-0 pointer-events-none"
                  style={{ background: 'repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(0,0,0,0.15) 2px, rgba(0,0,0,0.15) 4px)' }}
                />
                <div
                  className="absolute inset-0 pointer-events-none"
                  style={{ backgroundImage: 'linear-gradient(90deg,rgba(0,0,0,0.03) 1px,transparent 1px),linear-gradient(rgba(0,0,0,0.03) 1px,transparent 1px)', backgroundSize: '3px 3px' }}
                />
                <div className="absolute inset-0 bg-gradient-to-b from-[#9ea786]/40 via-transparent to-[#9ea786]/30 pointer-events-none" />
                <div
                  className="absolute inset-0 opacity-30 pointer-events-none"
                  style={{ background: 'linear-gradient(150deg, transparent 40%, rgba(255,255,255,0.3) 50%, transparent 60%)' }}
                />
              </div>
            </div>
          </div>

          {/* Main screen */}
          <div
            className="w-[242px] h-[242px] bg-zinc-800 rounded-full border-[10px] border-zinc-900 flex items-center justify-center relative"
            style={{ boxShadow: 'inset 0 8px 20px rgba(0,0,0,0.8), 0 4px 10px rgba(0,0,0,0.2)' }}
          >
            <div
              className="relative w-full h-full rounded-full scanlines glare overflow-hidden flex flex-col items-center justify-between p-3.5 border-4 border-zinc-700/50"
              style={customStyles.lcdBg}
            >
              {/* Icons row */}
              <div className="w-full flex justify-between px-6 pt-1 z-10">
                {/* Icon 1 */}
                <div className="w-4 h-4 bg-black/70 flex flex-col justify-end p-[1px]">
                  <div className="w-full h-1/2 bg-[#9ea786] rounded-t-full" />
                </div>
                {/* Icon 2 */}
                <div className="w-4 h-4 bg-black/70 rounded-full relative">
                  <div className="absolute bottom-[-2px] left-1 w-2 h-1.5 bg-black/70" />
                </div>
                {/* Icon 3 */}
                <div className="w-4 h-4 bg-black/70 rounded-sm flex items-center justify-center">
                  <div className="w-2 h-2 bg-[#9ea786] rounded-full" />
                </div>
                {/* Icon 4 */}
                <div className="w-4 h-4 bg-black/70 rounded-sm flex items-center justify-center">
                  <div className="w-3 h-1 bg-[#9ea786]" />
                  <div className="absolute w-1 h-3 bg-[#9ea786]" />
                </div>
              </div>

              {/* Pet */}
              <div className="relative z-10 flex-1 flex items-center justify-center">
                <div className="pet-animate relative">
                  {/* Pet body */}
                  <div className="w-16 h-14 bg-black/80 rounded-t-[1.5rem] rounded-b-lg relative">
                    {/* Left eye */}
                    <div className="absolute top-4 left-3 w-3 h-3 bg-[#9ea786] rounded-sm">
                      <div className="w-1 h-1 bg-black/80 mt-1 ml-1" />
                    </div>
                    {/* Right eye */}
                    <div className="absolute top-4 right-3 w-3 h-3 bg-[#9ea786] rounded-sm">
                      <div className="w-1 h-1 bg-black/80 mt-1 ml-1" />
                    </div>
                    {/* Mouth */}
                    <div className="absolute top-8 left-1/2 -translate-x-1/2 w-4 h-2 bg-[#9ea786] rounded-b-full" />
                    {/* Left ear */}
                    <div className="absolute top-8 -left-2 w-2 h-3 bg-black/80 rounded-l-full rotate-12" />
                    {/* Right ear */}
                    <div className="absolute top-8 -right-2 w-2 h-3 bg-black/80 rounded-r-full -rotate-12" />
                  </div>
                  {/* Shadow */}
                  <div className="absolute -bottom-2 left-1/2 -translate-x-1/2 w-12 h-2 bg-black/10 rounded-full blur-[1px]" />
                </div>
              </div>

              {/* Level text */}
              <div className="w-full flex justify-center pb-2 z-10">
                <span className="pixel-font text-xl text-black/80 tracking-widest font-bold">LVL 01</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default App;