+++
title = "Serialise and deserialise enums with named associated values from Rust → Swift"
date = 2023-02-02
[taxonomies]
tags=["Swift", "Rust", "JSON"]
+++

Between Rust and Serde and Swift and `Codable`, it's _relatively_ easy to serialise and deserialise between the 2, using JSON. Whilst there aren't shared definitions through a common format, such as Protobuf or MessagePack, for simple data it looks to be maintainable.

`serde_derive` and `Codable` deally save you writing encoders/serialisers and decoders/deserialisers. For Rust → Swift, I've so far had to write a decoder for enums with named associated values. Both Rust and Swift use nth-indexing for unnamed associated values, so I don't _think_ it would be too hard. Without associated values, decoding worked without having to write anything for decoding.

Here are small snippets of the types and decoder.

Rust[^1]:

```rust
#[derive(Debug, Copy, Clone, PartialEq, Deserialize, Serialize)]
pub enum State {
    Paused { duration: Duration },
    Stopped,
    Working { duration: Duration },
    TakingShortBreak { duration: Duration },
    TakingLongBreak { duration: Duration },
}
```

Swift[^2]:

```swift
@available(macOS 13.0, *)
enum State: Codable {
    case Paused(duration: Duration)
    case Stopped
    case Working(duration: Duration)
    case TakingShortBreak(duration: Duration)
    case TakingLongBreak(duration: Duration)

    enum CodingKeys: String, CodingKey {
        case Paused
        case Stopped
        case Working
        case TakingShortBreak
        case TakingLongBreak
    }

    enum AdditionalCodingKeys: String, CodingKey {
        case duration
        case secs
        case nanos
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let state = try? container.decode(String.self) {
            // For when it's "state":"Stopped"
            switch state {
            case "Stopped":
                self = .Stopped
            default:
                fatalError("Unexpected value \(state)")
            }
        } else {
            // For when "state":{"Working":{"duration":{"secs":1,"nanos":0}}}
            let values = try decoder.container(keyedBy: CodingKeys.self)

            // Dynamically get the CodingKey for the State from its enum
            let stateKey = values.allKeys.first!
            let stateContainer = try values.nestedContainer(
                keyedBy: AdditionalCodingKeys.self, forKey: stateKey
            )

            let durationKey = stateContainer.allKeys.first!
            let durationContainer = try stateContainer.nestedContainer(
                keyedBy: AdditionalCodingKeys.self, forKey: durationKey
            )

            let nanos = try durationContainer.decode(Int.self, forKey: .nanos)
            let secs = try durationContainer.decode(Int.self, forKey: .secs)

            let duration = Duration.nanoseconds(nanos) + Duration.seconds(secs)

            let state: State = {
                switch stateKey.stringValue {
                case "Paused":
                    return State.Paused(duration: duration)
                case "Working":
                    return State.Working(duration: duration)
                case "TakingShortBreak":
                    return State.TakingShortBreak(duration: duration)
                case "TakingLongBreak":
                    return State.TakingLongBreak(duration: duration)
                default:
                    fatalError("Unexpected value \(stateKey.stringValue)")
                }
            }()

            // Fake
            self = state
        }
    }
}
```

---

[^1]: [jesse-c/y-pomodoro/blob/5e808a251db8971c8987b6f9cd738d5173ba8adc/core/src/lib.rs](https://github.com/jesse-c/y-pomodoro/blob/5e808a251db8971c8987b6f9cd738d5173ba8adc/core/src/lib.rs#L45)

[^2]: [jesse-c/y-pomodoro/blob/5e808a251db8971c8987b6f9cd738d5173ba8adc/client/Sources/pomodoro/pomodoro.swift](https://github.com/jesse-c/y-pomodoro/blob/5e808a251db8971c8987b6f9cd738d5173ba8adc/client/Sources/pomodoro/pomodoro.swift#L72)
