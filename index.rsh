"reach 0.1";

const [isHand, H_ZERO, H_ONE, H_TWO, H_THREE, H_FOUR, H_FIVE] = makeEnum(6);
const [
  isResult,
  R_ZERO,
  R_ONE,
  R_TWO,
  R_THREE,
  R_FOUR,
  R_FIVE,
  R_SIX,
  R_SEVEN,
  R_EIGHT,
  R_NINE,
  R_TEN,
] = makeEnum(11);
const [isOutcome, Alex_WINS, DRAW, Fredi_WINS] = makeEnum(3);
const winner = (handAlex, handFredi, resultAlex, resultFredi) => {
  if (resultAlex == resultFredi) {
    return DRAW;
  }
  else if (handAlex + handFredi == resultAlex) {
    return Alex_WINS;
  } else if (handAlex + handFredi == resultFredi) {
    return Fredi_WINS;
  } else {
    return DRAW;
  }
};

assert(winner(H_ZERO, H_ZERO, R_ZERO, R_ZERO) == DRAW);
assert(winner(H_ZERO, H_ZERO, R_ONE, R_ZERO) == Fredi_WINS);
assert(winner(H_ZERO, H_ZERO, R_ZERO, R_ONE) == Alex_WINS);

forall(UInt, (handAlex) =>
  forall(UInt, (handFredi) =>
    forall(UInt, (resultAlex) =>
      forall(UInt, (resultFredi) =>
        assert(isOutcome(winner(handAlex, handFredi, resultAlex, resultFredi)))
      )
    )
  )
);

forall(UInt, (handAlex) =>
  forall(UInt, (handFredi) =>
    forall(UInt, (result) =>
      assert(winner(handAlex, handFredi, result, result) == DRAW)
    )
  )
);

const Player = {
  ...hasRandom,
  getHand: Fun([], UInt),
  getResult: Fun([], UInt),
  seeOutcome: Fun([UInt], Null),
  informTimeout: Fun([], Null),
};

export const main = Reach.App(() => {
  const Alex = Participant("Alex", {
    ...Player,
    wager: UInt,
    deadline: UInt,
  });
  const Fredi = Participant("Fredi", {
    ...Player,
    acceptWager: Fun([UInt], Null),
  });

  init();

  const informTimeout = () => {
    each([Alex, Fredi], () => {
      interact.informTimeout();
    });
  };

  Alex.only(() => {
    const amount = declassify(interact.wager);
    const deadline = declassify(interact.deadline);
  });

  Alex.publish(amount, deadline).pay(amount);
  commit();

  Fredi.only(() => {
    interact.acceptWager(amount);
  });
  Fredi.pay(amount).timeout(relativeTime(deadline), () =>
    closeTo(Alex, informTimeout)
  );

  var outcome = DRAW;
  invariant(balance() == 2 * amount && isOutcome(outcome));
  while (outcome == DRAW) {
    commit();

    Alex.only(() => {
      const _handAlex = interact.getHand();
      const [_commitHandAlex, _saltHandAlex] = makeCommitment(
        interact,
        _handAlex
      );
      const commitHandAlex = declassify(_commitHandAlex);
      
      const _resultAlex = interact.getResult();
      const [_commitResultAlex, _saltResultAlex] = makeCommitment(
        interact,
        _resultAlex
      );
      const commitResultAlex = declassify(_commitResultAlex);
    });

    Alex.publish(commitHandAlex, commitResultAlex).timeout(
      relativeTime(deadline),
      () => {
        closeTo(Fredi, informTimeout);
      }
    );
    commit();

    unknowable(
      Fredi,
      Alex(_handAlex, _saltHandAlex, _resultAlex, _saltResultAlex)
    );

    Fredi.only(() => {
      const handFredi = declassify(interact.getHand());
      const resultFredi = declassify(interact.getResult());
    });
    Fredi.publish(handFredi, resultFredi).timeout(relativeTime(deadline), () =>
      closeTo(Alex, informTimeout)
    );
    commit();

    Alex.only(() => {
      const saltHandAlex = declassify(_saltHandAlex);
      const handAlex = declassify(_handAlex);

      const saltResultAlex = declassify(_saltResultAlex);
      const resultAlex = declassify(_resultAlex);
    });
    Alex.publish(
      handAlex,
      saltHandAlex,
      resultAlex,
      saltResultAlex
    ).timeout(relativeTime(deadline), () => {
      closeTo(Fredi, informTimeout);
    });

    checkCommitment(commitHandAlex, saltHandAlex, handAlex);
    checkCommitment(commitResultAlex, saltResultAlex, resultAlex);
    outcome = winner(handAlex, handFredi, resultAlex, resultFredi);
    continue;
  } 

  assert(outcome == Alex_WINS || outcome == Fredi_WINS);

  transfer(2 * amount).to(outcome == Alex_WINS ? Alex : Fredi);
  commit();

  each([Alex, Fredi], () => {
    interact.seeOutcome(outcome);
  });
});
