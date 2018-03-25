import React from "react";
import ReactDOM from "react-dom";
import { Button, Row, Card, CardTitle, CardText } from "reactstrap";
import { Circle } from "react-shapes";
import { ToastContainer, toast } from "react-toastify";

export default function run_othello(root, channel) {
  ReactDOM.render(<Othello channel={channel} />, root);
}

class Othello extends React.Component {
  constructor(props) {
    super(props);
    this.channel = props.channel;
    this.user_name = props.channel.params.user_name;
    this.state = {
      game_board: [], //creating a board as that similar to othello
      black_player: "", // player playing with black discs
      white_player: "", // player playing with white discs
      observers: [], //  List of all the available observers for the game
      chats: [], //List of chats that have been generated
      player: "", // The player whose turn is to make a move
      black_disc: 0, // number of black disc
      white_disc: 0, // number of white disc
      legal_moves: [], // the legal moves available for the current disc
      game_status: "Waiting" // status of the game
    };

    this.channel.on("move", payload => {
      let game_state = payload.game_state;
      this.setState(game_state);
    });

    this.channel
      .join()
      .receive("ok", this.got_view.bind(this))
      .receive("error", resp => {
        console.log("Unable to join", resp);
      });
    this.make_move = this.make_move.bind(this);
    this.start_chat = this.start_chat.bind(this);

    this.channel.on("join", payload => {
      // console.log("state after joining");
      // console.log(payload.game_state);
      this.setState(payload.game_state);
    });

    this.channel.on("finish", payload => {
      // console.log("state after finishing");
      // console.log("game finished");
      this.setState(payload.game_state);
    });

    this.channel.on("player_msg", payload => {
      this.setState(payload.game_state);
    });
  }

  got_view(view) {
    console.log("state in joining");
    console.log(view.game);
    this.setState(view.game);
  }
  notify() {
    toast("Invalid MOVE!", {
      position: toast.POSITION.BOTTOM_CENTER
    });
  }

  /**
     let's begin by rendering only a single disc for the board
     */
  render_disc(row, col) {
    let disk = "";
    if (this.state.game_board.length != 0) {
      let diskState = this.state.game_board[row][col];
      if (diskState == 0) {
        disk = (
          <Button
            className="enabled-disk"
            onClick={() => this.make_move(row, col)}
          />
        );
      } else if (diskState == 1) {
        disk = (
          <div className="black disabled-disk">
            <div className="circle" />
          </div>
        );
      } else if (diskState == 2) {
        disk = (
          <div className="white disabled-disk">
            <div className="circle" />
          </div>
        );
      }
    }

    return disk;
  }

  /**
   * Rendering the game othello board
   */
  render_othello() {
    let rows = [];
    for (let i = 1; i <= 8; i++) {
      let cols = [];
      cols.push();
      for (let j = 0; j < 8; j++) {
        cols.push(
          <div className="col" key={"0" + j}>
            {" "}
            {this.render_disc(i - 1, j)}{" "}
          </div>
        );
      }
      let row = (
        <div className="row no-gutters" key={"1" + i}>
          {" "}
          {cols}{" "}
        </div>
      );
      rows.push(row);
    }

    return rows;
  }

  /**
   * Player moves the discs on the game board
   */
  make_move(row, col) {
    let user_name = this.channel.params.user_name;

    if (this.state.player != user_name) return;

    let size = this.state.game_board.length;
    let index = row * size + col;

    if (!this.state.legal_moves.includes(index)) {
      this.notify();
      return;
    }

    let identity = -1;

    if (user_name == this.state.white_player) identity = 2;
    else if (user_name == this.state.black_player) identity = 1;

    this.channel.push("move", {
      board: this.state.game_board,
      row: row,
      column: col,
      player_name: identity
    });
  }

  /** Check if the game is over or not and rende the message if game over*/
  render_game_over(over) {
    if (over) {
      if (this.state.black_disc > this.state.white_disc) {
        return (
          <div id="congrats" className="infoboard">
            Game Over!
            <br />
            {this.state.black_player} wins!
            <ExampleApp />
          </div>
        );
      } else {
        return (
          <div id="congrats">
            Game Over!
            <br />
            {this.state.white_player} wins!
          </div>
        );
      }
    } else {
      return <div>Game in Progress!</div>;
    }
  }

  start_chat(ev) {
    let inputMsg = document.querySelector("#inputMsg");
    let msg = inputMsg.value;
    this.channel.push("start_chat", { user_name: this.user_name, msg: msg });
    inputMsg.value = "";
  }

  render() {
    let chats = this.state.chats;
    let mainChat = [];

    for (let i = 0; i < chats.length; i++) {
      let firstChat = chats[i];
      let chatType = firstChat[0];
      let chatInfo = firstChat[1];
      let chatTypeClass = "";
      if (chatType == "system") {
        chatTypeClass = "systemMsg";
      } else if (chatType == "player") {
        chatTypeClass = "playerMsg";
      } else if (chatType == "observer") {
        chatTypeClass = "observerMsg";
      }

      mainChat.push(
        <div className={"row chattingMsg " + chatTypeClass} key={"msg" + i}>
          {" "}
          {chatInfo} <br />
        </div>
      );
    }

    let game_board = this.render_othello();
    let dark_player_status = "";
    let light_player_status = "";
    let over = false;

    if (this.state.white_disc + this.state.black_disc == 64) {
      over = true;
      console.log("Game over here #1");
    }

    if (this.state.black_player == "" || this.state.white_player == "") {
      dark_player_status = "Wait...";
      light_player_status = "Wait...";
      console.log("Here");
    } else if (this.state.player == this.state.black_player) {
      dark_player_status = "Your turn!";
      light_player_status = "Dark player's turn!";
      if (this.state.black_disc == 0 || this.state.black_disc == null) {
        over = true;
        console.log("Game over here #2");
      }
    } else {
      dark_player_status = "White player's turn!";
      light_player_status = "Your turn!";

      if (this.state.white_disc == 0 || this.state.white_disc == null) {
        over = true;
        console.log("Dark Pieces: " + this.state.black_disc);
        console.log("Game over here #3");
      }
    }

    let over_modal = this.render_game_over(over);

    return (
      <div>
        <div className="container-fluid" id="board">
          <div className="row">
            <div className="col-3 scoreboard">
              <Row className="card-row">
                <Card
                  body
                  inverse
                  style={{ backgroundColor: "#333", borderColor: "#333" }}
                >
                  <CardTitle className="title">
                    Player: {this.state.black_player}
                  </CardTitle>
                  <CardText>{dark_player_status}</CardText>
                </Card>
              </Row>
              <Row className="card-row">
                <Card body inverse color="danger">
                  <CardTitle className="title1">Score</CardTitle>
                  <CardText>
                    <Row className="title1 card-row">
                      <Circle r={15} fill={{ color: "#000000" }} /> &nbsp;
                      &nbsp;{this.state.black_disc} &nbsp;&nbsp;&nbsp;&nbsp;{" "}
                      {this.state.black_player}
                    </Row>
                    <Row className="title1 card-row">
                      <Circle r={15} fill={{ color: "#FFFFFF" }} /> &nbsp;
                      &nbsp;{this.state.white_disc} &nbsp;&nbsp;&nbsp;&nbsp;{" "}
                      {this.state.white_player}
                    </Row>
                  </CardText>
                </Card>
              </Row>
              <Row className="card-row">
                <Card body outline color="info">
                  <CardTitle className="title">
                    Player: {this.state.white_player}
                  </CardTitle>
                  <CardText>{light_player_status}</CardText>
                </Card>
              </Row>
              <Row className="card-row">
                <Card body inverse color="info">
                  <CardTitle className="title">Game Status</CardTitle>
                  <CardText>{over_modal}</CardText>
                </Card>
              </Row>
            </div>

            <div className="col-md-auto justify-content-center gameboard">
              {game_board}
            </div>

            <div className="col-3 offset-1">
              <div className="row" id="chatRoomHeader">
                Chat Room
              </div>
              <div className="row" id="chatRoomBody">
                <div className="container game-container">{mainChat}</div>
              </div>
              <div className="row">
                <input type="text" className="col-md-10" id="inputMsg" onKeyUp={event => event.keyCode === 13 && this.start_chat(event) }/>
                <Button className="col-md btn btn-primary"  onClick={this.start_chat}>
                  Send
                </Button>
              </div>
            </div>
          </div>
        </div>
        {/*Attribute: https://www.npmjs.com/package/react-toastify*/}
        <div>
          <ToastContainer className="title1" />
        </div>
      </div>
    );
  }
}
