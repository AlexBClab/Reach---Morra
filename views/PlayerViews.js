import React from "react";

const exports = {};

exports.GetHand = class extends React.Component {
  render() {
    const { parent, playable, hand } = this.props;
    return (
      <div>
        {hand ? "Draw! A new hand" : ""}
        <br />
        {!playable ? "Please wait..." : ""}
        <br />
        {"Please pick a hand"}
        <br />
        <br />
        <button disabled={!playable} onClick={() => parent.playHand(0)}>
          zero
        </button>
        <button disabled={!playable} onClick={() => parent.playHand(1)}>
          one
        </button>
        <button disabled={!playable} onClick={() => parent.playHand(2)}>
          two
        </button>
        <button disabled={!playable} onClick={() => parent.playHand(3)}>
          three
        </button>
        <button disabled={!playable} onClick={() => parent.playHand(4)}>
          four
        </button>
        <button disabled={!playable} onClick={() => parent.playHand(5)}>
          five
        </button>
      </div>
    );
  }
};

exports.GetResult = class extends React.Component {
  render() {
    //constants ?
    const { parent, playable, result } = this.props;
    return (
      <div>
        {result ? "It was a draw, result again!" : ""}
        <br />
        {!playable ? "Please Wait..." : ""}
        <br />
        {"Please result the total"}
        <br />
        <br />
        <button disabled={!playable} onClick={() => parent.playResult(0)}>
         zero
        </button>
        <button disable={!playable} onClick={() => parent.playResult(1)}>
          one
        </button>
        <button disable={!playable} onClick={() => parent.playResult(2)}>
          two
        </button>
        <button disable={!playable} onClick={() => parent.playResult(3)}>
          three
        </button>
        <button disable={!playable} onClick={() => parent.playResult(4)}>
          four
        </button>
        <button disable={!playable} onClick={() => parent.playResult(5)}>
          five
        </button>
        <button disable={!playable} onClick={() => parent.playResult(6)}>
          six
        </button>
        <button disable={!playable} onClick={() => parent.playResult(7)}>
          seven
        </button>
        <button disable={!playable} onClick={() => parent.playResult(8)}>
          eight
        </button>
        <button disable={!playable} onClick={() => parent.playResult(9)}>
          nine
        </button>
        <button disable={!playable} onClick={() => parent.playResult(10)}>
          ten
        </button>
      </div>
    );
  }
};


exports.WaitingForResults = class extends React.Component {
  render() {
    return <div>Waiting for results...</div>;
  }
};

exports.Done = class extends React.Component {
  render() {
    const { outcome } = this.props;
    return (
      <div>
        Thank you for playing. The outcome of this game was:
        <br />
        {outcome || "Unknown"}
      </div>
    );
  }
};

exports.Timeout = class extends React.Component {
  render() {
    return <div>There's been a timeout. (Someone took too long.)</div>;
  }
};

export default exports;
