import React from 'react';
import ReactDOM from 'react-dom';
import { Botton } from 'reactstrap';

export default function game_start(root, channel){
  ReactDOM.render(<Othello channel = {channel}/>, root);
}

// Extending React Component
class Othello extends React.Component
{
  constructor(props)
  {
    super(props);
    this.channel = props.channel;   // initialization

    this.state = {
      gameboard: [],        // Othello game board
      black_player: "",     // Black-side player's name
      white_player: "",     // White-side player's name
      observers: [],        // People watching the game
      current_player: "",   // Player whose turn is now [We start with white player]
      black_disk: 0,        // Number of black disks on the board
      white_disk: 0,        // Number of white disks on the boards
      valid_moves: []       // set of moves the current player can take
    }
  }
}
