import types

const
    KeyEvents* = {

        # Number Keys
        Key1, Key2, Key3,
        Key4, Key5, Key6,
        Key7, Key8, Key9,

        # Letter Keys
        KeyA, KeyB, KeyC, KeyD, KeyE, KeyF,
        KeyG, KeyH, KeyI, KeyJ, KeyK, KeyL,
        KeyM, KeyN, KeyO, KeyP, KeyQ, KeyR,
        KeyS, KeyT, KeyU, KeyV, KeyW, KeyX,
        KeyY, KeyZ,

    }

proc toCharString*(input: InputType): char =
    case input:
        of Key1: result = '1'
        of Key2: result = '2'
        of Key3: result = '3'
        of Key4: result = '4'
        of Key5: result = '5'
        of Key6: result = '6'
        of Key7: result = '7'
        of Key8: result = '8'
        of Key9: result = '9'
        of KeyA: result = 'a'
        of KeyB: result = 'b'
        of KeyC: result = 'c'
        of KeyD: result = 'd'
        of KeyE: result = 'e'
        of KeyF: result = 'f'
        of KeyG: result = 'g'
        of KeyH: result = 'h'
        of KeyI: result = 'i'
        of KeyJ: result = 'j'
        of KeyK: result = 'k'
        of KeyL: result = 'l'
        of KeyM: result = 'm'
        of KeyN: result = 'n'
        of KeyO: result = 'o'
        of KeyP: result = 'p'
        of KeyQ: result = 'q'
        of KeyR: result = 'r'
        of KeyS: result = 's'
        of KeyT: result = 't'
        of KeyU: result = 'u'
        of KeyV: result = 'v'
        of KeyW: result = 'w'
        of KeyX: result = 'x'
        of KeyY: result = 'y'
        of KeyZ: result = 'z'
        else: discard
