import Carbon.HIToolbox

struct KeyChoice: Identifiable, Hashable {
    let name: String
    let code: UInt32

    var id: UInt32 {
        code
    }

    static let all: [KeyChoice] = [
        KeyChoice(name: "A", code: UInt32(kVK_ANSI_A)),
        KeyChoice(name: "B", code: UInt32(kVK_ANSI_B)),
        KeyChoice(name: "C", code: UInt32(kVK_ANSI_C)),
        KeyChoice(name: "D", code: UInt32(kVK_ANSI_D)),
        KeyChoice(name: "E", code: UInt32(kVK_ANSI_E)),
        KeyChoice(name: "F", code: UInt32(kVK_ANSI_F)),
        KeyChoice(name: "G", code: UInt32(kVK_ANSI_G)),
        KeyChoice(name: "H", code: UInt32(kVK_ANSI_H)),
        KeyChoice(name: "I", code: UInt32(kVK_ANSI_I)),
        KeyChoice(name: "J", code: UInt32(kVK_ANSI_J)),
        KeyChoice(name: "K", code: UInt32(kVK_ANSI_K)),
        KeyChoice(name: "L", code: UInt32(kVK_ANSI_L)),
        KeyChoice(name: "M", code: UInt32(kVK_ANSI_M)),
        KeyChoice(name: "N", code: UInt32(kVK_ANSI_N)),
        KeyChoice(name: "O", code: UInt32(kVK_ANSI_O)),
        KeyChoice(name: "P", code: UInt32(kVK_ANSI_P)),
        KeyChoice(name: "Q", code: UInt32(kVK_ANSI_Q)),
        KeyChoice(name: "R", code: UInt32(kVK_ANSI_R)),
        KeyChoice(name: "S", code: UInt32(kVK_ANSI_S)),
        KeyChoice(name: "T", code: UInt32(kVK_ANSI_T)),
        KeyChoice(name: "U", code: UInt32(kVK_ANSI_U)),
        KeyChoice(name: "V", code: UInt32(kVK_ANSI_V)),
        KeyChoice(name: "W", code: UInt32(kVK_ANSI_W)),
        KeyChoice(name: "X", code: UInt32(kVK_ANSI_X)),
        KeyChoice(name: "Y", code: UInt32(kVK_ANSI_Y)),
        KeyChoice(name: "Z", code: UInt32(kVK_ANSI_Z)),
        KeyChoice(name: "0", code: UInt32(kVK_ANSI_0)),
        KeyChoice(name: "1", code: UInt32(kVK_ANSI_1)),
        KeyChoice(name: "2", code: UInt32(kVK_ANSI_2)),
        KeyChoice(name: "3", code: UInt32(kVK_ANSI_3)),
        KeyChoice(name: "4", code: UInt32(kVK_ANSI_4)),
        KeyChoice(name: "5", code: UInt32(kVK_ANSI_5)),
        KeyChoice(name: "6", code: UInt32(kVK_ANSI_6)),
        KeyChoice(name: "7", code: UInt32(kVK_ANSI_7)),
        KeyChoice(name: "8", code: UInt32(kVK_ANSI_8)),
        KeyChoice(name: "9", code: UInt32(kVK_ANSI_9)),
    ]
}
