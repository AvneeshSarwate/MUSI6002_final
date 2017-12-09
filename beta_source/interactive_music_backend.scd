(
var midiOut, chords, markov, normalize, markovStep, tempoClock, state, playChord, chordStep, markovNorm;


midiOut = MIDIOut.newByName("IAC Driver", "Bus 2");

chords = List.new;

chords.add([60, 64, 67, 72]);
chords.add([57, 62, 65, 69]);
chords.add([55, 59, 62, 65]);
chords.add([53, 57, 60, 65]);
chords.add([54, 57, 60, 62]);

c = chords;

state = 0;

markov = [
    [9, 8, 7, 6, 5],
    [4, 3, 2, 1, 2],
    [9, 8, 7, 6, 5],
    [4, 3, 2, 1, 2],
    [9, 8, 7, 6, 5],
];

normalize = {|markovMat|
    var normMat = markovMat.deepCopy;
    normMat.size.do({|ind|
        normMat[ind] = normMat[ind] / normMat[ind].sum
    });
    normMat
};

markovStep = {|transitions, state|
    var stateTrans = transitions.[state];
    var rand = 1.0.rand;
    var accum = stateTrans[0];
    var newState = block {|break| stateTrans.size.do({|ind|
        if(rand < accum,
            {break.value(ind)},
            {accum = accum+stateTrans[ind+1]}
        )
    })};
    newState
};

markovNorm = normalize.(markov);

playChord = {|chord|
    var waitTime = [0.5, 0.75, 0.25].choose;
    ["CHORD PLAY", chord].postln;
    chord.do({|note|
        Task({
            midiOut.noteOn(1, note);
            (waitTime-0.05).wait;
            midiOut.noteOff(1, note);
        }, tempoClock).play;
    });
    waitTime
};

chordStep = {
    var waitTime;
    state = markovStep.(markovNorm, state);
    waitTime = playChord.(chords[state]);
    ["CHORD PLAYED", state].postln;
    waitTime;
};

    //TODO: move variable instations to near the functions that use them
OSCFunc({|msg, time, addr, recvPort|
    //msg[1] is the new BEAT DURATION (not tempo)
    tempoClock = TempoClock.new(1/msg[1], 0);
    //t = tempoClock;
    tempoClock.sched(0,chordStep);
    "MULTILOOP ONE SHOT".postln;

}, "/masterClockBeat").oneShot;



)




//================================================================================================
//================================================================================================

(

var markov = [
    [1, 1, 0, 0, 0],
    [0, 1, 1, 0, 0],
    [0, 0, 1, 1, 0],
    [0, 0, 0, 1, 1],
    [1, 0, 0, 0, 1],
];

var normalize = {|markovMat|
    var normMat = markovMat.deepCopy;
    normMat.size.do({|ind|
        normMat[ind] = normMat[ind] / normMat[ind].sum
    });
    normMat
};

var norm = normalize.(markov);

var state = 0;

var markovStep = {|transitions, state|
    var stateTrans = transitions.[state];
    var rand = 1.0.rand;
    var accum = stateTrans[0];
    var newState = block {|break| stateTrans.size.do({|ind|
        if(rand < accum,
            {break.value(ind)},
            {accum = accum+stateTrans[ind+1]}
        )
    })};
    newState
};
(0..10).do({
    state = markovStep.(norm, state);
    state.postln;
})
)
