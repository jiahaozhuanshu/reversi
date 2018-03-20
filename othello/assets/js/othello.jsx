import React from 'react';
import ReactDOM from 'react-dom';
import { Button } from 'reactstrap';

export default function run_othello(root, channel) {
  ReactDOM.render(<Othello channel={channel}/>, root);
}

/*
state
  vals: the tile values to be displayed as a list of 16 values
  colors: the colors of the tiles as a list of 16 colors
  score: the current game score
*/
class Othello extends React.Component
{
  constructor(props)
  {
    super(props);
    this.channel = props.channel;

    this.state = {
      vals: ['', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''],
      colors: ['seconday', 'seconday', 'seconday', 'seconday',
        'seconday', 'seconday', 'seconday', 'seconday',
        'seconday', 'seconday', 'seconday', 'seconday',
        'seconday', 'seconday', 'seconday', 'seconday'],
      score: 0
    };

    this.channel.join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => {console.log("Unable to join", resp)});
  }

  // resets the view upon receiving an updated game state from the controller
  // sends a subsequent "match" message to the channel if two tiles are selected
  gotView(view)
  {
    // console.log("New view", view);
    this.setState(view.game);

    let selections = _.filter(this.state.colors, (c) => c == "primary");

    if (selections.length == 2) {
      setTimeout(
        () => this.channel.push("match").receive("ok", this.gotView.bind(this)),
        1000
      );
    }
  }

  // event handler for tile selections
  // uses closure to pass tile index to the channel message
  sendSelection(index)
  {
      let i = index;
      let c = this.channel;
      let gv = this.gotView.bind(this);

      return function (ev) {
        c.push("select", { index: i })
          .receive("ok", gv);
      }
  }

  // resets the state of the game with newly randomized tile values
  // waits a second before executing to allow previously waiting calls
  // to complete their execution
  reset() {
    setTimeout(
      () => this.channel.push("reset").receive("ok", this.gotView.bind(this)),
      1000
    );
  }

  render() {
    return (
      <div>
        <div className="container game">
          <div className="row">
            <Tile
              state={this.state}
              select={this.sendSelection.bind(this)}
              index={0} />
            <Tile
              state={this.state}
              select={this.sendSelection.bind(this)}
              index={1} />
            <Tile
              state={this.state}
              select={this.sendSelection.bind(this)}
              index={2} />
            <Tile
              state={this.state}
              select={this.sendSelection.bind(this)}
              index={3} />
          </div>
          <div className="row">
            <Tile
              state={this.state}
              select={this.sendSelection.bind(this)}
              index={4} />
            <Tile
              state={this.state}
              select={this.sendSelection.bind(this)}
              index={5} />
            <Tile
              state={this.state}
              select={this.sendSelection.bind(this)}
              index={6} />
            <Tile
              state={this.state}
              select={this.sendSelection.bind(this)}
              index={7} />
          </div>
          <div className="row">
            <Tile
              state={this.state}
              select={this.sendSelection.bind(this)}
              index={8} />
            <Tile
              state={this.state}
              select={this.sendSelection.bind(this)}
              index={9} />
            <Tile
              state={this.state}
              select={this.sendSelection.bind(this)}
              index={10} />
            <Tile
              state={this.state}
              select={this.sendSelection.bind(this)}
              index={11} />
          </div>
          <div className="row">
            <Tile
              state={this.state}
              select={this.sendSelection.bind(this)}
              index={12} />
            <Tile
              state={this.state}
              select={this.sendSelection.bind(this)}
              index={13} />
            <Tile
              state={this.state}
              select={this.sendSelection.bind(this)}
              index={14} />
            <Tile
              state={this.state}
              select={this.sendSelection.bind(this)}
              index={15} />
          </div>
          <div className="row">
            <div className="col-6">
              <h3>Current Score: {this.state.score}</h3>
            </div>
            <div className="col-6">
              <Button className="reset" color="warning"
                onClick={this.reset.bind(this)}>
                reset
              </Button>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

// the main component of the game containing a Button
function Tile(props) {
  let index = props.index;
  let clr = props.state.colors[index];
  let disp = props.state.vals[index];

  return (
    <div className="col-3">
      <div className="spacer"></div>
      <Button className="memCard" color={clr} onClick={props.select(index)}>
        {disp}
      </Button>
    </div>
  );
}
