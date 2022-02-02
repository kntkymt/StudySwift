// MARK: - Memberwise Initilizer

// memberwise initilizerで初期化した場合
// デフォルト値が定義されていてもデフォルト値を代入せずmemberwise initilizerの引数が一度だけ代入される
// custom initilizerで初期化した場合
// デフォルト値が定義されている変数は二回代入される
// 生成したインスタンスの数だけカウントが増えるクラス
final class CountA {
    static var count = 0

    public init() {
        Self.count += 1
    }
}

final class CountB {
    static var count = 0

    public init() {
        Self.count += 1
    }
}

final class CountC {
    static var count = 0

    public init() {
        Self.count += 1
    }
}

struct SizeA {
    // デフォルト値を設定
    var count: CountA = CountA()

    // custom initilizer
    init(count: CountA) {
        self.count = count
    }
}

struct SizeB {
    // デフォルト値を設定
    var count: CountB = CountB()

    // memberwise initilizer
}

class SizeC {
    var count: CountC = CountC()

    init(count: CountC) {
        self.count = count
    }
}

let sizeA = SizeA(count: CountA())
print(CountA.count) // 2

let sizeB = SizeB(count: CountB())
print(CountB.count) // 1

let sizeC = SizeC(count: CountC())
print(CountC.count) // 2

// MARK: - Initializer Delegation

struct Point {
    var x: Double = 0.0
    var y: Double = 0.0
}
struct Size {
    var width: Double = 0.0
    var height: Double = 0.0
}

struct Rect {
    var origin: Point
    var size: Size
}

// extensionでinitを宣言すればmemberwise initilizerを使ったままinitを追加できる
// structはconvenient等の概念が存在しないので普通にinitの連鎖
extension Rect {
    init(center: Point, size: Size) {
        let originX = center.x - (size.width / 2)
        let originY = center.y - (size.height / 2)
        self.init(origin: Point(x: originX, y: originY), size: size)
    }
}

let rect = Rect(center: .init(), size: .init())

// classで他のinitを呼ぶinitはConvenience initとなる
class RectClass {
    var origin: Point
    var size: Size

    // designated initializer
    init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }

    // こういうのもdesignated initializerで作れるが、designated initializerは最小限にすべきなので
    // やるならconvenience initializerにすべき
    init(size: Size)  {
        self.origin = .init()
        self.size = size
    }
}

extension RectClass {
    convenience init(center: Point, size: Size) {
        let originX = center.x - (size.width / 2)
        let originY = center.y - (size.height / 2)

        // 最終的にはdesignated initializerを呼ぶべき
        self.init(origin: Point(x: originX, y: originY), size: size)
    }

    // convenienceからconvenienceはOK
    convenience init()  {
        self.init(origin: .init(), size: .init())

        // Convenienceでは、self. はdesignated initializerを読んだ後でないと使えない
        print(self.origin.x)
    }
}

let rectClass = RectClass(center: .init(), size: .init())

// MARK: - Initializer Inheritance and Overriding

class Hoge {
    var name: String

    init(name: String) {
        self.name = name
    }

    convenience init() {
        self.init(name: "Unknown")
    }
}

// designatedはsuperのdesignatedを呼ぶ
// convenienceはselfのinitを呼び、最終的にはselfのdesignatedを呼ぶ
// designated  -> super designated  OK
// designated  -> super convenience NG
// convenience -> super designated  NG
// convenience -> super convenience NG
// overrideできるのはdesignatedだけ
class Fuga: Hoge {
    var old: Int

    init(old: Int, name: String) {
        self.old = old
        // designated
        // super.init()
        super.init(name: name)
    }

    // superのdesignatedをoverrideしてconvenienceにすることもある
    override convenience init(name: String) {
        // convenienceでsuperは呼べない
        // super.init(name: name)

        self.init(old: 10, name: name)
    }

    // convenienceはoverideできない
    // override init() {}
    convenience init() {
        self.init(old: 10, name: "")
    }
}

// MARK: - Automatic Initializer Inheritance

class Food {
    var name: String

    init(name: String) {
        self.name = name
    }
    convenience init() {
        self.init(name: "[Unnamed]")
    }
}

// どのdesignated initializerもoverrideしていない場合、designatedが継承され
// desiganatedが継承されるとconvenienceも継承される
class CookedFood: Food {
}
let cookedFood1 = CookedFood()
let cookedFood2 = CookedFood(name: "sushi")

// 新しく変数を追加した場合は初期値を与えれば、↑と同じ
class BurnedFood: Food {
    var quantity: Int = 1
}
let burnedFood1 = BurnedFood()
let burnedFood2 = BurnedFood(name: "Yakiniku")

// 全てのdesignatedをoverrideしている場合はconvenienceが継承される
class RecipeIngredient: Food {
    var quantity: Int

    init(name: String, quantity: Int) {
        self.quantity = quantity
        super.init(name: name)
    }

    override convenience init(name: String) {
        self.init(name: "override convenience", quantity: 1)
    }
}

let ingredient1 = RecipeIngredient() // super.convenience
// super.convenienceで呼ばれるinit(name: )が、self.のinit(name: )になっている
print(ingredient1.name) // "override convenience"

let ingredient2 = RecipeIngredient(name: "Onion") // self.convenience
let ingredient3 = RecipeIngredient(name: "Onion", quantity: 1) // self.designated

class Foo {
    var name: String

    init(name: String) {
        self.name = name
    }

    init(fullname: String) {
        self.name = String(fullname.prefix(while: { String($0) == " " }))
    }

    convenience init() {
        self.init(name: "[Unnamed]")
    }
}

class Bar: Foo {
    var old: Int

    init(name: String, old: Int) {
        self.old = old
        super.init(name: name)
    }

    override convenience init(name: String) {
        self.init(name: "override convenience", old: 0)
    }
}

// 直接super.convenienceで使っていなくても、designatedを全てoverrideしないとconvenienceは継承されない
// let bar = Bar()

// MARK: - Required Initializers

class Super {
    var hoge: Int

    init(hoge: Int) {
        self.hoge = hoge
    }
}

class Sub: Super {
    var fuga: Int

    init(hoge: Int, fuga: Int) {
        self.fuga = fuga
        super.init(hoge: hoge)
    }

    override convenience init(hoge: Int) {
        self.init(hoge: hoge, fuga: 10)
    }
}

class RequiredSuper {
    var hoge: Int

    required init(hoge: Int) {
        self.hoge = hoge
    }
}

class RequireSub: RequiredSuper {

    var fuga: Int

    init(hoge: Int, fuga: Int) {
        self.fuga = fuga
        super.init(hoge: hoge)
    }

    required init(hoge: Int) {
        // もちろんfugaもinitしなくてはいけない
        // requiredを定義すると言うことは、最悪そのinitだけで成り立つようにクラスを設計しろってこと？
        self.fuga = 10
        super.init(hoge: hoge)
    }
}

// Requiredじゃないとジェネリクスで使えない
// Constructing an object of class type 'T' with a metatype value must use a 'required' initializer
//func createSub<T: Super>(type: T.Type, hoge: Int) {
//    let sub = T.init(hoge: hoge)
//}

func createSub<T: RequiredSuper>(type: T.Type, hoge: Int) -> T {
    return T.init(hoge: hoge)
}
