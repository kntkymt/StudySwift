final class A1Strong {

    var b: B1!

    func doSomething() {
        print("\(#function)")
    }

    init() {
        print("A1 Strong init")

        self.b = B1(handler: {
            // Strong reference
            print("self: \(self)")
            self.doSomething()
        })
    }

    deinit {
        print("A1 Strong deinit")
    }
}

final class A1Weak {

    var b: B1!

    func doSomething() {
        print("\(#function)")
    }

    init() {
        print("A1 Weak init")
        self.b = B1(handler: { [weak self] in
            // Weak reference
            print("self: \(self)")
            self?.doSomething()
        })
    }

    deinit {
        print("A1 Weak deinit")
    }
}

final class A1Unowned {

    var b: B1!

    func doSomething() {
        print("\(#function)")
    }

    init() {
        print("A1 Unowned init")
        self.b = B1(handler: { [unowned self] in
            print("self: \(self)")
            self.doSomething()
        })
    }

    deinit {
        print("A1 Unowned deinit")
    }
}

final class B1 {
    var handler: () -> Void

    init(handler: @escaping () -> Void) {
        print("B1 init")
        self.handler = handler
    }

    deinit {
        print("B1 deinit")
    }
}

do {
    let b1: B1
    do {
        // strongだとAもB解放されない、循環参照でメモリリーク
        let a1 = A1Strong()

        // weak, unownedだと解放される、
//        let a1 = A1Weak()
//        let a1 = A1Unowned()

        b1 = a1.b
    }

    // aのスコープが外れた後にaを参照してるクロージャーを呼ぶ
    // strong: 普通に呼ばれる
    // weak: selfがnilになってる
    // unowned: selfがないので落ちる
    b1.handler()
}

print()

final class A2Strong {

    init() {
        print("A2 Strong init")
        B2.shared.handlers.append({
            self.doSomething()
        })
    }

    func doSomething() {
        print("\(#function)")
    }

    deinit {
        print("A2 Strong deinit")
    }
}

final class A2Weak {

    init() {
        print("A2 Weak init")
        B2.shared.handlers.append({ [weak self] in
            print("self: \(self)")
            self?.doSomething()
        })
    }

    func doSomething() {
        print("\(#function)")
    }

    deinit {
        print("A2 Weak deinit")
    }
}

final class A2Unowned {
    init() {
        print("A2 Unowned init")
        B2.shared.handlers.append({ [unowned self] in
            print("self: \(self)")
            self.doSomething()
        })
    }

    func doSomething() {
        print("\(#function)")
    }

    deinit {
        print("A2 Unowned deinit")
    }
}

// シングルトンとか
final class B2 {

    static let shared = B2()

    var handlers: [() -> Void] = []

    init() {
        print("B2 init")
    }

    deinit {
        print("B2 deinit")
    }
}

do {
    do {
        // strongだとAもB解放されない、循環参照でメモリリーク
        let a2 = A2Strong()

        // weak, unownedだと解放される、
//        let a2 = A2Weak()
//        let a2 = A2Unowned()
    }

    // aのスコープが外れた後にaを参照してるクロージャーを呼ぶ
    // strong: 普通に呼ばれる
    // weak: selfがnilになってる
    // unowned: selfがないので落ちる
    B2.shared.handlers.forEach {
        $0()
    }
}
