(
var midiOut, chords, markov, normalize, markovStep;

60	64	67	72
57	62	65	69
55	59	62	65
53	57	60	65
54	57	60	62

chords = List.new;

chords.add([60, 64, 67, 72]);
chords.add([57, 62, 65, 69]);
chords.add([55, 59, 62, 65]);
chords.add([53, 57, 60, 65]);
chords.add([54, 57, 60, 62]);

c = chords;

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
