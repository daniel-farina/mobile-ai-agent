import React, { useState, useEffect } from 'react';
import './App.css';

const BOARD_WIDTH = 10;
const BOARD_HEIGHT = 20;
const TICK_SPEED = 500;

const createEmptyBoard = () => Array(BOARD_HEIGHT).fill().map(() => Array(BOARD_WIDTH).fill(0));

const TETROMINOS = {
  'I': [[1,1,1,1]],
  'O': [[1,1], [1,1]],
  'T': [[0,1,0], [1,1,1]],
  'L': [[1,0], [1,0], [1,1]]
};

function App() {
  const [board, setBoard] = useState(createEmptyBoard());
  const [piece, setPiece] = useState(null);
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const [score, setScore] = useState(0);

  const spawnPiece = () => {
    const pieces = Object.keys(TETROMINOS);
    const newPiece = TETROMINOS[pieces[Math.floor(Math.random() * pieces.length)]];
    setPiece(newPiece);
    setPosition({ x: Math.floor(BOARD_WIDTH / 2) - 1, y: 0 });
  };

  const moveLeft = () => {
    if (position.x > 0) {
      setPosition(prev => ({ ...prev, x: prev.x - 1 }));
    }
  };

  const moveRight = () => {
    if (position.x < BOARD_WIDTH - (piece?.[0]?.length || 0)) {
      setPosition(prev => ({ ...prev, x: prev.x + 1 }));
    }
  };

  const moveDown = () => {
    if (position.y < BOARD_HEIGHT - (piece?.length || 0)) {
      setPosition(prev => ({ ...prev, y: prev.y + 1 }));
    } else {
      placePiece();
    }
  };

  const placePiece = () => {
    if (!piece) return;
    
    const newBoard = [...board];
    piece.forEach((row, y) => {
      row.forEach((cell, x) => {
        if (cell) {
          newBoard[position.y + y][position.x + x] = 1;
        }
      });
    });
    
    setBoard(newBoard);
    spawnPiece();
    setScore(prev => prev + 10);
  };

  useEffect(() => {
    if (!piece) {
      spawnPiece();
    }
    
    const interval = setInterval(moveDown, TICK_SPEED);
    return () => clearInterval(interval);
  }, [piece]);

  const renderBoard = () => {
    const displayBoard = board.map(row => [...row]);
    
    if (piece) {
      piece.forEach((row, y) => {
        row.forEach((cell, x) => {
          if (cell) {
            displayBoard[position.y + y][position.x + x] = 1;
          }
        });
      });
    }

    return displayBoard.map((row, y) => 
      row.map((cell, x) => (
        <div 
          key={`${y}-${x}`} 
          className={`cell ${cell ? 'filled' : ''}`} 
        />
      ))
    );
  };

  return (
    <div className="game-container">
      <div className="score">Score: {score}</div>
      <div className="board">
        {renderBoard()}
      </div>
      <div className="controls">
        <button onClick={moveLeft}>←</button>
        <button onClick={moveDown}>↓</button>
        <button onClick={moveRight}>→</button>
      </div>
    </div>
  );
}

export default App;