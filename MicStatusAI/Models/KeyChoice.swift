import Carbon.HIToolbox

struct KeyChoice: Identifiable, Hashable {
    let name: String
    let code: UInt32

    var id: UInt32 {
        code
    }

    static let all: [Self] = [
        Self(name: "A", code: UInt32(kVK_ANSI_A)),
        Self(name: "B", code: UInt32(kVK_ANSI_B)),
        Self(name: "C", code: UInt32(kVK_ANSI_C)),
        Self(name: "D", code: UInt32(kVK_ANSI_D)),
        Self(name: "E", code: UInt32(kVK_ANSI_E)),
        Self(name: "F", code: UInt32(kVK_ANSI_F)),
        Self(name: "G", code: UInt32(kVK_ANSI_G)),
        Self(name: "H", code: UInt32(kVK_ANSI_H)),
        Self(name: "I", code: UInt32(kVK_ANSI_I)),
        Self(name: "J", code: UInt32(kVK_ANSI_J)),
        Self(name: "K", code: UInt32(kVK_ANSI_K)),
        Self(name: "L", code: UInt32(kVK_ANSI_L)),
        Self(name: "M", code: UInt32(kVK_ANSI_M)),
        Self(name: "N", code: UInt32(kVK_ANSI_N)),
        Self(name: "O", code: UInt32(kVK_ANSI_O)),
        Self(name: "P", code: UInt32(kVK_ANSI_P)),
        Self(name: "Q", code: UInt32(kVK_ANSI_Q)),
        Self(name: "R", code: UInt32(kVK_ANSI_R)),
        Self(name: "S", code: UInt32(kVK_ANSI_S)),
        Self(name: "T", code: UInt32(kVK_ANSI_T)),
        Self(name: "U", code: UInt32(kVK_ANSI_U)),
        Self(name: "V", code: UInt32(kVK_ANSI_V)),
        Self(name: "W", code: UInt32(kVK_ANSI_W)),
        Self(name: "X", code: UInt32(kVK_ANSI_X)),
        Self(name: "Y", code: UInt32(kVK_ANSI_Y)),
        Self(name: "Z", code: UInt32(kVK_ANSI_Z)),
        Self(name: "0", code: UInt32(kVK_ANSI_0)),
        Self(name: "1", code: UInt32(kVK_ANSI_1)),
        Self(name: "2", code: UInt32(kVK_ANSI_2)),
        Self(name: "3", code: UInt32(kVK_ANSI_3)),
        Self(name: "4", code: UInt32(kVK_ANSI_4)),
        Self(name: "5", code: UInt32(kVK_ANSI_5)),
        Self(name: "6", code: UInt32(kVK_ANSI_6)),
        Self(name: "7", code: UInt32(kVK_ANSI_7)),
        Self(name: "8", code: UInt32(kVK_ANSI_8)),
        Self(name: "9", code: UInt32(kVK_ANSI_9)),
    ]
}
