(
var midiOutVox, chords, markov, normalize, markovStep, tempoClock, state, playChord, chordStep, markovNorm, altChords, chordTask, bassLineTask, counterTask, lineFunction, maxPort, pythonPort, lineInd, onsetBuffer;

MIDIClient.init;
MIDIIn.connectAll;

midiOutVox = MIDIOut.newByName("IAC Driver", "Bus 2");
midiOutBass = MIDIOut.newByName("IAC Driver", "Bus 2");
maxPort = NetAddr("127.0.0.1", 1234);
pythonPort = NetAddr("127.0.0.1", 6002);
tempoClock = TempoClock.new(1, 0);

chords = List.new;

chords.add([60, 64, 67, 72]);
chords.add([57, 62, 65, 69]);
chords.add([55, 59, 62, 65]);
chords.add([53, 57, 60, 65]);
chords.add([54, 57, 60, 62]);

chords = List.new;

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
            midiOutVox.noteOn(1, note);
            (waitTime-0.05).wait;
            midiOutVox.noteOff(1, note);
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


onsetBuffer = List.new;
OSCFunc({|msg, time, addr, recvPort|
    onsetBuffer.add(tempoClock.beats);
}, "/onset");

playNote = {|note, dur|
    Task({
        midiOutBass.noteOn(1, note);
        dur.wait - 0.05;
        midiOutBass.noteOff(note);
    }).play;
    dur;
}









generateAndStartBassLine = {
    var startBeat = onsetBuffer[0].floor;
    var hitBuffer = onsetBuffer - startBeat;
    var endBeat = onsetBuffer.wrapAt(-1).ceil;

    (0..(hitBuffer.size-1)).do({|i|
        var hit = hitBuffer[i];
        var timeToNextHit = ~quantizeValue - (hit % ~quantizeValue);
        var nextHit = hit + timeToNextHit;
        var lastHit = nextHit - ~quantizeValue;
        hitBuffer[i] = if((lastHit-hit).abs < (nextHit-hit).abs, lastHit, nextHit);
    });

    var duplicateRemovedHits = List.newFrom(Set.newFrom(hitBuffer)).sort;
    duplicateRemovedHits.add(endBeat);
    var durations = List.new
    (0..(duplicateRemovedHits.length-2)).do({|i|
        durations.add(duplicateRemovedHits[i+1] - duplicateRemovedHits[i]);
    });

    Task({
        durations.do({|dur|
            var note = activeChord.choose - 12;
            playNote(note, dur).wait;
        })
    }).play;

    onsetBuffer = List.new;
};




~secondsPerLine = 3;
lineInd = 0;
~quantizeValue = 1/4;

counterTask = Task({
    var ind = 0;
    var quantizeVal = 1/4;

    {
        if(ind == 0, {
            pythonPort.sendMsg("/getLine", lineInd);
            generateAndStartBassLine.();
            lineInd = lineInd + 1;
        });
        (~secondsPerLine/100).wait;
        maxPort.sendMsg("/counterStep", ind);
        ind = (ind + 1) % 100;


    }.loop

}, tempoClock);
counterTask.play;

)


//================================================================================================
//================================================================================================






(


a = List.newFrom(Set.newFrom([1, 2, 3, 3])).sort;


a.postln


)

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
