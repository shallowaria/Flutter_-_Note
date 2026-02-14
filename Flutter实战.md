##随记

### context和build

在 Flutter 中：

- `context` 是作为 `build` 的**参数**传进来的。
- 这意味着你只能在 `build` 方法内部，或者从 `build` 传出去的方法里使用它。

需要执行向上操作查找时需要context,即React内的`useContext Hook`，避免Prop Drilling

| **概念**     | **React (Hook 风格)**                    | **Flutter**                                  |
| ------------ | ---------------------------------------- | -------------------------------------------- |
| **提供者**   | `<ThemeContext.Provider value={...}>`    | `Theme(...)` 组件                            |
| **消费者**   | `const theme = useContext(ThemeContext)` | `Theme.of(context)`                          |
| **定位器**   | 虚拟 DOM 树的位置                        | `BuildContext` (context)                     |
| **底层机制** | Fiber 树向上查找                         | Element 树向上查找 (`visitAncestorElements`) |

比如查找数据`Theme.of(context)`、交互与路由`Navigator.push(context, ...)`、获取屏幕信息`MediaQuery.of(context)`



#### A. 原始组件（Leaf Widgets）

像 `Text`、`Image`、`Padding`。它们是由 Flutter 内部直接实现的，不依赖 `build` 方法来组合其他 Widget。它们直接对应底层的渲染逻辑。

#### B. 组合组件（Composed Widgets）

就是你写的 `StatelessWidget` 或 `StatefulWidget`。

- 这些组件本身**不具备渲染能力**。
- 它们的作用是**“编剧”**。`build` 方法就是剧本，告诉 Flutter：“我这个组件其实是由一个 `Column`、一个 `Text` 和一个 `Button` 组成的。”
- **必须要 `build`：** 框架需要调用你的 `build` 方法，并传给你一个 `context`，这样你才能在你的“剧本”里使用 `Theme.of(context)` 等需要定位的功能。



Flutter 中如果属性发生变化则会重新构建Widget树，即重新创建新的 Widget 实例来替换旧的 Widget 实例

- `Key`: 这个`key`属性类似于 React/Vue 中的`key`，主要的作用是决定是否在下一次`build`时复用旧的 widget ，决定的条件在`canUpdate()`方法中。

- `canUpdate(...)`是一个静态方法，它主要用于在 widget 树重新`build`时复用旧的 widget ，其实具体来说，应该是：是否用新的 widget 对象去更新旧UI树上所对应的`Element`对象的配置；通过其源码我们可以看到，只要`newWidget`与`oldWidget`的`runtimeType`和`key`同时相等时就会用`new widget`去更新`Element`对象的配置，否则就会创建新的`Element`。



Flutter 框架的处理流程是这样的：

根据 Widget 树生成一个 Element 树，Element 树中的节点都继承自 Element 类。
根据 Element 树生成 Render 树（渲染树），渲染树中的节点都继承自RenderObject 类。
根据渲染树生成 Layer 树，然后上屏显示，Layer 树中的节点都继承自 Layer 类。
真正的布局和渲染逻辑在 Render 树中，Element 是 Widget 和 RenderObject 的粘合剂，可以理解为一个中间代理。我们通过一个例子来说明，假设有如下 Widget 树：

```dart
Container( // 一个容器 widget
  color: Colors.blue, // 设置容器背景色
  child: Row( // 可以将子widget沿水平方向排列
    children: [
      Image.network('https://www.example.com/1.png'), // 显示图片的 widget
      const Text('A'),
    ],
  ),
);
```


注意，如果 Container 设置了背景色，Container 内部会创建一个新的 ColoredBox 来填充背景，相关逻辑如下：

if (color != null)
  current = ColoredBox(color: color!, child: current);
而 Image 内部会通过 RawImage 来渲染图片、Text 内部会通过 RichText 来渲染文本，所以最终的 Widget树、Element 树、渲染树结构如图2-2所示：

![image-20260210214600917](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260210214600917.png)

State 中的保存的状态信息可以：

1. 在 widget 构建时可以被同步读取。
2. 在 widget 生命周期中可以被改变，当State被改变时，可以手动调用其`setState()`方法通知Flutter 框架状态发生改变，Flutter 框架在收到消息后，会重新调用其`build`方法重新构建 widget 树，从而达到更新UI的目的。

### State生命周期

- `initState`：当 widget 第一次插入到 widget 树时会被调用，对于每一个State对象，Flutter 框架只会调用一次该回调，所以，通常在该回调中做一些一次性的操作，如状态初始化、订阅子树的事件通知等。不能在该回调中调用`BuildContext.dependOnInheritedWidgetOfExactType`（该方法用于在 widget 树上获取离当前 widget 最近的一个父级`InheritedWidget`，关于`InheritedWidget`我们将在后面章节介绍），原因是在初始化完成后， widget 树中的`InheritFrom widget`也可能会发生变化，所以正确的做法应该在在`build（）`方法或`didChangeDependencies()`中调用它。
- `didChangeDependencies()`：当State对象的依赖发生变化时会被调用；例如：在之前`build()` 中包含了一个`InheritedWidget` （第七章介绍），然后在之后的`build()` 中`Inherited widget`发生了变化，那么此时`InheritedWidget`的子 widget 的`didChangeDependencies()`回调都会被调用。典型的场景是当系统语言 Locale 或应用主题改变时，Flutter 框架会通知 widget 调用此回调。需要注意，组件第一次被创建后挂载的时候（包括重创建）对应的`didChangeDependencies`也会被调用。
- `build()`：此回调读者现在应该已经相当熟悉了，它主要是用于构建 widget 子树的，会在如下场景被调用：
  1. 在调用`initState()`之后。
  2. 在调用`didUpdateWidget()`之后。
  3. 在调用`setState()`之后。
  4. 在调用`didChangeDependencies()`之后。
  5. 在State对象从树中一个位置移除后（会调用deactivate）又重新插入到树的其他位置之后。
- `reassemble()`：此回调是专门为了开发调试而提供的，在热重载(hot reload)时会被调用，此回调在Release模式下永远不会被调用。
- `didUpdateWidget ()`：在 widget 重新构建时，Flutter 框架会调用`widget.canUpdate`来检测 widget 树中同一位置的新旧节点，然后决定是否需要更新，如果`widget.canUpdate`返回`true`则会调用此回调。正如之前所述，`widget.canUpdate`会在新旧 widget 的 `key` 和 `runtimeType` 同时相等时会返回true，也就是说在在新旧 widget 的key和runtimeType同时相等时`didUpdateWidget()`就会被调用。
- `deactivate()`：当 State 对象从树中被移除时，会调用此回调。在一些场景下，Flutter 框架会将 State 对象重新插到树中，如包含此 State 对象的子树在树的一个位置移动到另一个位置时（可以通过GlobalKey 来实现）。如果移除后没有重新插入到树中则紧接着会调用`dispose()`方法。
- `dispose()`：当 State 对象从树中被永久移除时调用；通常在此回调中释放资源。

![image-20260210230220577](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260210230220577.png)







- 如果状态是用户数据，如复选框的选中状态、滑块的位置，则该状态最好由父 Widget 管理。
- 如果状态是有关界面外观效果的，例如颜色、动画，那么状态最好由 Widget 本身来管理。
- 如果某一个状态是不同 Widget 共享的则最好由它们共同的父 Widget 管理。



![image-20260212124225955](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260212124225955.png)

在`TipRoute`页中有两种方式可以返回到上一页；第一种方式是直接点击导航栏返回箭头，第二种方式是点击页面中的“返回”按钮。这两种返回方式的区别是前者不会返回数据(null)给上一个路由，而后者会。



### 路由route

- Navigator（push pop） 
- MaterialPageRoute(builder)
- 命名路由 路由表(MaterialApp内) pushNamed 传参 onGenerateRoute 

推荐统一使用命名路由的管理方式

1. 语义化更明确。
2. 代码更好维护；如果使用匿名路由，则必须在调用`Navigator.push`的地方创建新路由页，这样不仅需要import新路由页的dart文件，而且这样的代码将会非常分散。
3. 可以通过`onGenerateRoute`做一些全局的路由跳转前置处理逻辑。

### 资源assets

文字

![image-20260212204905375](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260212204905375.png)

- …/my_icon.png
- …/2.0x/my_icon.png
- …/3.0x/my_icon.png

AssetImage / Image.asset

```
// 普通加载
AssetImage('graphics/background.png'),
Image.asset('graphics/background.png')
// 依赖包中的
AssetImage('icons/heart.png', package: 'my_icons')
Image.asset('icons/heart.png', package: 'my_icons')
```

### of context

**of(context)` 本质上就是 React 的 `useContext` 的 Flutter 版实现。**

1. 核心概念：BuildContext 是什么？

在解释 `of(context)` 之前，得先知道 `context`。

- **context（上下文）**：是当前组件在整个 **Widget Tree（组件树）** 中的“坐标”或“句柄”。
- 它告诉 Flutter：我现在在哪里。

2. `of(context)` 的工作原理

当你调用 `Navigator.of(context)` 时，发生的事情如下：

1. **定位**：从你当前的组件位置（`context`）开始。
2. **溯源**：沿着组件树一层一层往**上**找（向根节点方向）。
3. **获取**：寻找最近的一个 `NavigatorState` 实例。
4. **返回**：一旦找到，就返回这个实例，让你能调用它的 `push`、`pop` 等方法。

### 安卓图标更换位置

`.../android/app/src/main/res`

> **注意:** 如果您重命名.png文件，则还必须在您`AndroidManifest.xml`的`<application>`标签的`android:icon`属性中更新名称。

`D:\code\2026-2\flutter_fight\android\app\src\main\AndroidManifest.xml`

### 调试

debugger() 插入断点

print debugPrint(会分批输出，推荐)

打断点

动画：请将[timeDilation](https://docs.flutter.io/flutter/scheduler/timeDilation.html)·变量（在scheduler库中）设置为大于1.0的数字，例如50.0

Dev Tools: Dart: CTRL+Shift+P

 Flutter: Inspect Widget

 Dart:Open DevTools 

### 异常捕获

![image-20260212213248056](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260212213248056.png)

和JS类似，Dart中可以通过`try/catch/finally`来捕获代码块异常，因为其也是单线程

### final 和 const

**`final`：** “我的心里只有你”，但我允许你（对象）改变发型、换衣服。

**`const`：** “我的心里只有你”，且你必须像雕像一样永远保持这个姿势，动一下都不行。

## 基础组件

### Text

属性

textAlign 对齐方式 对齐的参考系是Text widget 本身

maxLines overflow 指定行数和截断方式 `TextOverflow.ellipsis`

textScaler 缩放因子，调节fontSize，可从`MediaQueryData.textScaleFactor`获得默认值

### TextStyle

`style: TextStyle()`

### TextSpan

Text.rich 下实现

### 字体

同图片 在`pubspec.yaml`中声明然后使用

### 按钮

共同点：

1. 按下时都会有“水波动画”（又称“涟漪动画”，就是点击时按钮上会出现水波扩散的动画）。
2. 有一个`onPressed`属性来设置点击回调，当按钮按下时会执行该回调，如果不提供该回调则按钮会处于禁用状态，禁用状态不响应用户点击。

- `ElevatedButton` 即"漂浮"按钮，它默认带有阴影和灰色背景。按下后，阴影会变大
- `TextButton`即文本按钮，默认背景透明并不带阴影。按下后，会有背景色
- `OutlinedButton`默认有一个边框，不带阴影且背景透明。按下后，边框颜色会变亮、同时出现背景和阴影(较弱)
- `IconButton`是一个可点击的Icon，不包括文字，默认没有背景，点击后会出现背景
- Elevated Text Outlined 都有.icon 组件，附带图标

### 图片和图标

#### 图片

加载本地图片 网络图片

图片常用参数

![image-20260213080545575](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260213080545575.png)

- 当不指定宽高时，图片会根据当前父容器的限制，尽可能的显示其原始大小，如果只设置`width`、`height`的其中一个，那么另一个属性默认会按比例缩放

- fit的值：

  ![image-20260213080749104](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260213080749104.png)

- `color`指定混合色，而`colorBlendMode`指定混合模式`

- ```dart
  color: Colors.blue,
    colorBlendMode: BlendMode.difference,
  ```

  

#### 图标

在Flutter开发中，iconfont和图片相比有如下优势：

1. 体积小：可以减小安装包大小。
2. 矢量的：iconfont都是矢量图标，放大不会影响其清晰度。
3. 可以应用文本样式：可以像文本一样改变字体图标的颜色、大小对齐等。
4. 可以通过TextSpan和文本混用。

### 单选开关和复选框

- Switch
- Checkbox
- activeThumbColor activeColor
- Checkbox三态 tristate 给状态加?
- 只负责通知，父组件管理状态

### 输入框及表单

- TextField
- 获取内容 1.onChanged获取 2.实例化TextEditingController 赋予TextFiled的controller

## 布局类组件

![image-20260213151556341](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260213151556341.png)

布局类组件就是指直接或间接继承(包含)`SingleChildRenderObjectWidget` 和`MultiChildRenderObjectWidget`的Widget，它们一般都会有一个`child`或`children`属性用于接收子 Widget。我们看一下继承关系 Widget > RenderObjectWidget > (Leaf/SingleChild/MultiChild)RenderObjectWidget 。

`RenderObjectWidget`类中定义了创建、更新`RenderObject`的方法，子类必须实现他们，关于`RenderObject`我们现在只需要知道它是最终布局、渲染UI界面的对象即可，也就是说，对于布局类组件来说，其布局算法都是通过对应的`RenderObject`对象来实现的



###布局模型：

Flutter 中有两种布局模型：

- 基于 RenderBox 的盒模型布局。
- 基于 Sliver ( RenderSliver ) 按需加载列表布局。

两种布局方式在细节上略有差异，但大体流程相同，布局流程如下：

1. 上层组件向下层组件传递约束（constraints）条件。
2. 下层组件确定自己的大小，然后告诉上层组件。注意下层组件的大小必须符合父组件的约束。
3. 上层组件确定下层组件相对于自身的偏移和确定自身的大小（大多数情况下会根据子组件的大小来确定自身的大小）。

比如，父组件传递给子组件的约束是“最大宽高不能超过100，最小宽高为0”，如果我们给子组件设置宽高都为200，则子组件最终的大小是100*100，**因为任何时候子组件都必须先遵守父组件的约束**，在此基础上再应用子组件约束（相当于父组件的约束和自身的大小求一个交集）。

#### 盒模型布局 (Constraints)

特点：

1. 组件对应的渲染对象都继承自 RenderBox 类。在本书后面文章中如果提到某个组件是 RenderBox，则指它是基于盒模型布局的，而不是说组件是 RenderBox 类的实例。
2. 在布局过程中父级传递给子级的约束信息由 BoxConstraints 描述。

父级组件是通过 BoxConstraints 来描述对子组件可用的空间范围

> 约定：为了描述方便，如果我们说一个组件不约束其子组件或者取消对子组件约束时是指对子组件约束的最大宽高为无限大，而最小宽高为0，相当于子组件完全可以自己根据需要的空间来确定自己的大小。

在实际开发中，当我们发现已经使用 `SizedBox` 或 `ConstrainedBox`给子元素指定了固定宽高，但是仍然没有效果时，几乎可以断定：已经有父组件指定了约束！

实际上`ConstrainedBox`和`SizedBox`都是通过`RenderConstrainedBox`来渲染的，我们可以看到`ConstrainedBox`和`SizedBox`的`createRenderObject()`方法都返回的是一个`RenderConstrainedBox`对象

### 线性布局 (Row Column)

`Row`和`Column`都继承自`Flex`

**`Row`和`Column`都只会在主轴方向占用尽可能大的空间，而纵轴的长度则取决于他们最大子元素的长度**

```dart
// 居中对齐思路 将Column的宽度指定为屏幕宽度 通过ConstrainedBox或SizedBox
ConstrainedBox(
  constraints: BoxConstraints(minWidth: double.infinity), 
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Text("hi"),
      Text("world"),
    ],
  ),
);
```



对于线性布局，有主轴和纵轴之分，如果布局是沿水平方向，那么主轴就是指水平方向，而纵轴即垂直方向；如果布局沿垂直方向，那么主轴就是指垂直方向，而纵轴就是水平方向。在线性布局中，有两个定义对齐方式的枚举类`MainAxisAlignment`和`CrossAxisAlignment`，分别代表主轴对齐和纵轴对齐。

#### Row

- `textDirection`：表示水平方向子组件的布局顺序(是从左往右还是从右往左)，默认为系统当前Locale环境的文本方向(如中文、英语都是从左往右，而阿拉伯语是从右往左)。
- `mainAxisSize`：表示`Row`在主轴(水平)方向占用的空间，默认是`MainAxisSize.max`，表示尽可能多的占用水平方向的空间，此时无论子 widgets 实际占用多少水平空间，`Row`的宽度始终等于水平方向的最大宽度；而`MainAxisSize.min`表示尽可能少的占用水平空间，当子组件没有占满水平剩余空间，则`Row`的实际宽度等于所有子组件占用的水平空间；
- `mainAxisAlignment`：表示子组件在`Row`所占用的水平空间内对齐方式，如果`mainAxisSize`值为`MainAxisSize.min`，则此属性无意义，因为子组件的宽度等于`Row`的宽度。只有当`mainAxisSize`的值为`MainAxisSize.max`时，此属性才有意义，`MainAxisAlignment.start`表示沿`textDirection`的初始方向对齐，如`textDirection`取值为`TextDirection.ltr`时，则`MainAxisAlignment.start`表示左对齐，`textDirection`取值为`TextDirection.rtl`时表示从右对齐。而`MainAxisAlignment.end`和`MainAxisAlignment.start`正好相反；`MainAxisAlignment.center`表示居中对齐。读者可以这么理解：`textDirection`是`mainAxisAlignment`的参考系。
- `verticalDirection`：表示`Row`纵轴（垂直）的对齐方向，默认是`VerticalDirection.down`，表示从上到下。
- `crossAxisAlignment`：表示子组件在纵轴方向的对齐方式，`Row`的高度等于子组件中最高的子元素高度，它的取值和`MainAxisAlignment`一样(包含`start`、`end`、 `center`三个值)，不同的是`crossAxisAlignment`的参考系是`verticalDirection`，即`verticalDirection`值为`VerticalDirection.down`时`crossAxisAlignment.start`指顶部对齐，`verticalDirection`值为`VerticalDirection.up`时，`crossAxisAlignment.start`指底部对齐；而`crossAxisAlignment.end`和`crossAxisAlignment.start`正好相反；
- `children` ：子组件数组。

#### Column

`Column`可以在垂直方向排列其子组件。参数和`Row`一样，不同的是布局方向为垂直

如果`Row`里面嵌套`Row`，或者`Column`里面再嵌套`Column`，那么只有最外面的`Row`或`Column`会占用尽可能大的空间，里面`Row`或`Column`所占用的空间为实际大小

```dart
Container(
  color: Colors.green,
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max, //有效，外层Colum高度为整个屏幕
      children: <Widget>[
        Container(
          color: Colors.red,
          child: Column(
            mainAxisSize: MainAxisSize.max,//无效，内层Colum高度为实际高度  
            children: <Widget>[
              Text("hello world "),
              Text("I am Jack "),
            ],
          ),
        )
      ],
    ),
  ),
);

```

如果要让里面的`Column`占满外部`Column`，可以使用`Expanded` 组件：

```dart
Expanded( 
  child: Container(
    color: Colors.red,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, //垂直方向居中对齐
      children: <Widget>[
        Text("hello world "),
        Text("I am Jack "),
      ],
    ),
  ),
)
```

### 弹性布局（Flex）

- Flex, 使用Row Column 更方便
- Expanded只能作为 Flex 的孩子，它可以按比例“扩伸”`Flex`子组件所占用的空间，必须包含child
- `Spacer`的功能是占用指定比例的空间，没有child，就是Expanded(child: SizedBox.shrink())

### 流式布局（Wrap、Flow）

超出屏幕显示范围会自动折行的布局称为流式布局

#### Wrap

```dart
spacing：主轴方向子widget的间距
runSpacing：纵轴方向的间距
runAlignment：纵轴方向的对齐方式
```

####Flow

一般很少会使用`Flow`，因为其过于复杂，需要自己实现子 widget 的位置转换，在很多场景下首先要考虑的是`Wrap`是否满足需求。`Flow`主要用于一些需要自定义布局策略或性能要求较高(如动画中)的场景。

### 层叠布局 (Stack、Positioned)

层叠布局和 Web 中的绝对定位是相似的,子组件可以根据距父容器四个角的位置来确定自身的位置。层叠布局允许子组件按照代码中声明的顺序堆叠起来。Flutter中使用`Stack`和`Positioned`这两个组件来配合实现绝对定位。`Stack`允许子组件堆叠，而`Positioned`用于根据`Stack`的四个角来确定子组件的位置。

#### Stack

- `alignment`：此参数决定如何去对齐没有定位（没有使用`Positioned`）或部分定位的子组件。所谓部分定位，在这里**特指没有在某一个轴上定位：**`left`、`right`为横轴，`top`、`bottom`为纵轴，只要包含某个轴上的一个定位属性就算在该轴上有定位。
- `textDirection`：和`Row`、`Wrap`的`textDirection`功能一样，都用于确定`alignment`对齐的参考系，即：`textDirection`的值为`TextDirection.ltr`，则`alignment`的`start`代表左，`end`代表右，即`从左往右`的顺序；`textDirection`的值为`TextDirection.rtl`，则alignment的`start`代表右，`end`代表左，即`从右往左`的顺序。
- `fit`：此参数用于确定**没有定位**的子组件如何去适应`Stack`的大小。`StackFit.loose`表示使用子组件的大小，`StackFit.expand`表示扩伸到`Stack`的大小。
- `clipBehavior`：此属性决定对超出`Stack`显示空间的部分如何剪裁，Clip枚举类中定义了剪裁的方式，Clip.hardEdge 表示直接剪裁，不应用抗锯齿，更多信息可以查看源码注释。

#### Positioned

`left`、`top` 、`right`、 `bottom`分别代表离`Stack`左、上、右、底四边的距离。`width`和`height`用于指定需要定位元素的宽度和高度。注意，`Positioned`的`width`、`height` 和其他地方的意义稍微有点区别，此处用于配合`left`、`top` 、`right`、 `bottom`来定位组件，举个例子，在水平方向时，你只能指定`left`、`right`、`width`三个属性中的两个，如指定`left`和`width`后，`right`会自动算出(`left`+`width`)，如果同时指定三个属性则会报错，垂直方向同理。

### 对齐与相对定位 (Align)

#### Align

`Stack`和`Positioned`，可以指定一个或多个子元素相对于父元素各个边的精确偏移，并且可以重叠。但如果只想简单的调整**一个**子元素在父元素中的位置的话，使用`Align`组件会更简单一些。

属性：

- `alignment` : 需要一个`AlignmentGeometry`类型的值，表示子组件在父组件中的起始位置。`AlignmentGeometry` 是一个抽象类，它有两个常用的子类：`Alignment`和 `FractionalOffset`，我们将在下面的示例中详细介绍。

`Alignment(this.x, this.y)``Alignment` Widget会以**矩形的中心点作为坐标原点**，即`Alignment(0.0, 0.0)` 。`x`、`y`的值从-1到1分别代表矩形左边到右边的距离和顶部到底边的距离

推荐FranctionalOffset

`FractionalOffset` 继承自 `Alignment`，它和 `Alignment`唯一的区别就是坐标原点不同！`FractionalOffset` 的坐标原点为矩形的左侧顶点，这和布局系统的一致，所以理解起来会比较容易。

```text
实际偏移 = (FractionalOffse.x * (parentWidth - childWidth), FractionalOffse.y * (parentHeight - childHeight))
```

- `widthFactor`和`heightFactor`是用于确定`Align` 组件本身宽高的属性；它们是两个缩放因子，会分别乘以子元素的宽、高，最终的结果就是`Align` 组件的宽高。如果值为`null`，则组件的宽高将会占用尽可能多的空间。

  Alignment(2,0.0) 实际偏移坐标为（90，30）距离上，距离左的距离

```dart
Container(
  height: 120.0,
  width: 120.0,
  color: Colors.blue.shade50,
  child:Align(
      widthFactor: 2,
      heightFactor: 2,
      alignment: Alignment.topRight,
      child: FlutterLogo(
        size: 60,
      ),
),
```

![image-20260213173158550](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260213173158550.png)

#### Center

​	 居中

### LayoutBuilder

#### LayoutBuilder

在**布局过程**中拿到父组件传递的约束信息，然后我们可以根据约束信息动态的构建不同的布局。

##容器组件

###DecoratedBox

`DecoratedBox`可以在其子组件绘制前(或后)绘制一些装饰（Decoration）

- `decoration`：代表将要绘制的装饰，它的类型为`Decoration`。`Decoration`是一个抽象类，它定义了一个接口 `createBoxPainter()`，子类的主要职责是需要通过实现它来创建一个画笔，该画笔用于绘制装饰。
- `position`：此属性决定在哪里绘制`Decoration`，它接收`DecorationPosition`的枚举类型，该枚举类有两个值：
  - `background`：在子组件之后绘制，即背景装饰。
  - `foreground`：在子组件之上绘制，即前景。

####BoxDecoration

我们==通常会直接使用`BoxDecoration`类==，它是一个Decoration的子类，实现了常用的装饰元素的绘制。

```dart
BoxDecoration({
  Color color, //颜色
  DecorationImage image,//图片
  BoxBorder border, //边框
  BorderRadiusGeometry borderRadius, //圆角
  List<BoxShadow> boxShadow, //阴影,可以指定多个
  Gradient gradient, //渐变
  BlendMode backgroundBlendMode, //背景混合模式
  BoxShape shape = BoxShape.rectangle, //形状
})

```

示例：

```dart
 DecoratedBox(
   decoration: BoxDecoration(
     gradient: LinearGradient(colors:[Colors.red,Colors.orange.shade700]), //背景渐变
     borderRadius: BorderRadius.circular(3.0), //3像素圆角
     boxShadow: [ //阴影
       BoxShadow(
         color:Colors.black54,
         offset: Offset(2.0,2.0),
         blurRadius: 4.0
       )
     ]
   ),
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 18.0),
    child: Text("Login", style: TextStyle(color: Colors.white),),
  )
)
```

![image-20260213180603496](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260213180603496.png)

### 变换 Transform

`Transform`可以在其子组件绘制时对其应用一些矩阵变换来实现一些特效。`Matrix4`是一个4D矩阵

```dart
Container(
  color: Colors.black,
  child: Transform(
    alignment: Alignment.topRight, //相对于坐标系原点的对齐方式
    transform: Matrix4.skewY(0.3), //沿Y轴倾斜0.3弧度
    child: Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.deepOrange,
      child: const Text('Apartment for rent!'),
    ),
  ),
)
```

![image-20260213180732206](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260213180732206.png)

> 由于矩阵变化时发生在绘制时，而无需重新布局和构建等过程，所以性能很好。

#### 平移

`Transform.translate`接收一个`offset`参数，可以在绘制时沿`x`、`y`轴对子组件平移指定的距离。

```dart
DecoratedBox(
  decoration:BoxDecoration(color: Colors.red),
  //默认原点为左上角，左移20像素，向上平移5像素  
  child: Transform.translate(
    offset: Offset(-20.0, -5.0),
    child: Text("Hello world"),
  ),
)
```

![image-20260213181531788](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260213181531788.png)

#### 旋转

Transform.rotate可以对子组件进行旋转变换

```dart
DecoratedBox(
  decoration:BoxDecoration(color: Colors.red),
  child: Transform.rotate(
    //旋转90度
    angle:math.pi/2 ,
    child: Text("Hello world"),
  ),
)
```

> 注意：要使用`math.pi`需先进行如下导包。

`import 'dart:math' as math;  `

![image-20260213181631994](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260213181631994.png)

#### 缩放

`Transform.scale`可以对子组件进行缩小或放大

```dart
DecoratedBox(
  decoration:BoxDecoration(color: Colors.red),
  child: Transform.scale(
    scale: 1.5, //放大到1.5倍
    child: Text("Hello world")
  )
);
```

####Tip

`Transform`的变换是应用在绘制阶段，而并不是应用在布局(layout)阶段，所以无论对子组件应用何种变化，其占用空间的大小和在屏幕上的位置都是固定不变的，因为这些是在布局阶段就确定的。

#### RotatedBox

`RotatedBox`和`Transform.rotate`功能相似，它们都可以对子组件进行旋转变换，但是有一点不同：`RotatedBox`的变换是在layout阶段，会影响在子组件的位置和大小。

### 容器 Container

- container padding margin

### 裁剪 Clip

| 剪裁Widget | 默认行为                                                 |
| ---------- | -------------------------------------------------------- |
| ClipOval   | 子组件为正方形时剪裁成内贴圆形；为矩形时，剪裁成内贴椭圆 |
| ClipRRect  | 将子组件剪裁为圆角矩形                                   |
| ClipRect   | 默认剪裁掉子组件布局空间之外的绘制内容（溢出部分剪裁）   |
| ClipPath   | 按照自定义的路径剪裁                                     |

###空间适配

- FittedBox 动态调整以防止溢出

###页面骨架

- Scaffold

## 可滚动组件

1. ListView 中的列表项组件都是 RenderBox，**并不是 Sliver**， 这个一定要注意。
2. 一个 ListView 中只有一个Sliver，对列表项进行按需加载的逻辑是 Sliver 中实现的。
3. ListView 的 Sliver 默认是 SliverList，如果指定了 `itemExtent` ，则会使用 SliverFixedExtentList；如果 `prototypeItem` 属性不为空，则会使用 SliverPrototypeExtentList，无论是是哪个，都实现了子组件的按需加载模型。

###基础概念

- 基于 Sliver ( RenderSliver ) 按需加载列表布局。
- Sliver 可以包含一个或多个子组件。Sliver 的主要作用是配合：加载子组件并确定每一个子组件的布局和绘制信息，如果 Sliver 可以包含多个子组件时，通常会实现按需加载模型。可滚动组件中有很多都支持基于Sliver的按需加载模型，如`ListView`、`GridView`，但是也有不支持该模型的，如`SingleChildScrollView`

Flutter 中的可滚动组件主要由三个角色组成：Scrollable、Viewport 和 Sliver：

- Scrollable ：用于处理滑动手势，确定滑动偏移，滑动偏移变化时构建 Viewport 。
- Viewport：显示的视窗，即列表的可视区域；
- Sliver：视窗里显示的元素。

具体布局过程：

1. Scrollable 监听到用户滑动行为后，根据最新的滑动偏移构建 Viewport 。
2. Viewport 将当前视口信息和配置信息通过 SliverConstraints 传递给 Sliver。
3. Sliver 中对子组件（RenderBox）按需进行构建和布局，然后确认自身的位置、绘制等信息，保存在 geometry 中（一个 SliverGeometry 类型的对象）。

![image-20260213205826805](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260213205826805.png)

图中白色区域为设备屏幕，也是 Scrollable 、 Viewport 和 Sliver 所占用的空间，三者所占用的空间重合，父子关系为：Sliver 父组件为 Viewport，Viewport的 父组件为 Scrollable 。注意ListView 中只有一个 Sliver，在 Sliver 中实现了子组件（列表项）的按需加载和布局。

其中顶部和底部灰色的区域为 cacheExtent，它表示预渲染的高度，需要注意这是在可视区域之外，如果 RenderBox 进入这个区域内，即使它还未显示在屏幕上，也是要先进行构建的，预渲染是为了后面进入 Viewport 的时候更丝滑。cacheExtent 的默认值是 250，在构建可滚动列表时我们可以指定这个值，这个值最终会传给 Viewport。

####Scrollable

用于处理滑动手势，确定滑动偏移，滑动偏移变化时构建 Viewport

- `axisDirection` 滚动方向。
- `physics`：此属性接受一个`ScrollPhysics`类型的对象，它决定可滚动组件如何响应用户操作，比如用户滑动完抬起手指后，继续执行动画；或者滑动到边界时，如何显示。Flutter SDK中包含了两个`ScrollPhysics`的子类，他们可以直接使用：
  - `ClampingScrollPhysics`：列表滑动到边界时将不能继续滑动，通常在Android 中 配合 `GlowingOverscrollIndicator`（实现微光效果的组件） 使用。
  - `BouncingScrollPhysics`：iOS 下弹性效果。
- `controller`：此属性接受一个`ScrollController`对象。`ScrollController`的主要作用是控制滚动位置和监听滚动事件。默认情况下，Widget树中会有一个默认的`PrimaryScrollController`，如果子树中的可滚动组件没有显式的指定`controller`，并且`primary`属性值为`true`时（默认就为`true`），可滚动组件会使用这个默认的`PrimaryScrollController`。这种机制带来的好处是父组件可以控制子树中可滚动组件的滚动行为。
- `viewportBuilder`：构建 Viewport 的回调。当用户滑动时，Scrollable 会调用此回调构建新的 Viewport，同时传递一个 ViewportOffset 类型的 offset 参数，该参数描述 Viewport 应该显示那一部分内容。注意重新构建 Viewport 并不是一个昂贵的操作，因为 Viewport 本身也是 Widget，只是配置信息，Viewport 变化时对应的 RenderViewport 会更新信息，并不会随着 Widget 进行重新构建。

在可滚动组件的坐标描述中，通常将滚动方向称为主轴，非滚动方向称为纵轴。由于可滚动组件的默认方向一般都是沿垂直方向，所以默认情况下主轴就是指垂直方向，水平方向同理。

#### Viewport

Viewport 比较简单，用于渲染当前视口中需要显示 Sliver。

![image-20260213210835151](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260213210835151.png)

- offset：该参数为Scrollabel 构建 Viewport 时传入，它描述了 Viewport 应该显示那一部分内容。
- cacheExtent 和 cacheExtentStyle：CacheExtentStyle 是一个枚举，有 pixel 和 viewport 两个取值。当 cacheExtentStyle 值为 pixel 时，cacheExtent 的值为预渲染区域的具体像素长度；当值为 viewport 时，cacheExtent 的值是一个乘数，表示有几个 viewport 的长度，最终的预渲染区域的像素长度为：cacheExtent * viewport 的积， 这在每一个列表项都占满整个 Viewport 时比较实用，这时 cacheExtent 的值就表示前后各缓存几个页面。

#### Sliver

Sliver 主要作用是对子组件进行构建和布局，比如 ListView 的 Sliver 需要实现子组件（列表项）按需加载功能，只有当列表项进入预渲染区域时才会去对它进行构建和布局、渲染。

Sliver 对应的渲染对象类型是 RenderSliver，RenderSliver 和 RenderBox 的相同点是都继承自 RenderObject 类，不同点是在布局的时候约束信息不同。RenderBox 在布局时父组件传递给它的约束信息对应的是 `BoxConstraints`，只包含最大宽高的约束；而 RenderSliver 在布局时父组件（列表）传递给它的约束是对应的是 `SliverConstraints`。

#### 通用配置

几乎所有的可滚动组件在构造时都能指定 `scrollDirection`（滑动的主轴）、`reverse`（滑动方向是否反向）、`controller`、`physics` 、`cacheExtent` ，这些属性最终会透传给对应的 Scrollable 和 Viewport，这些属性我们可以认为是可滚动组件的通用属性

#### ScrollController

可滚动组件都有一个 controller 属性，通过该属性我们可以指定一个 ScrollController 来控制可滚动组件的滚动，比如可以通过ScrollController来同步多个组件的滑动联动。

#### 子节点缓存

 //TODO

#### Scrollbar

`Scrollbar`是一个Material风格的滚动指示器（滚动条），如果要给可滚动组件添加滚动条，只需将`Scrollbar`作为可滚动组件的任意一个父级组件即可

```dart
Scrollbar(
  child: SingleChildScrollView(
    ...
  ),
);
```

### SingleChildScrollView

SingleChildScrollView**只能接收一个子组件**

![image-20260213211413030](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260213211413030.png)

`primary`属性：它表示是否使用 widget 树中默认的`PrimaryScrollController`（MaterialApp 组件树中已经默认包含一个 PrimaryScrollController 了）；当滑动方向为垂直方向（`scrollDirection`值为`Axis.vertical`）并且没有指定`controller`时，`primary`默认为`true`

### ListView

#### 默认构造函数



`ListView`是最常用的可滚动组件之一，它可以沿一个方向线性排布所有子组件，并且它也支持列表项懒加载（在需要时才会创建）。

构造函数定义：

```dart
ListView({
  ...  
  //可滚动widget公共参数
  Axis scrollDirection = Axis.vertical,
  bool reverse = false,
  ScrollController? controller,
  bool? primary,
  ScrollPhysics? physics,
  EdgeInsetsGeometry? padding,
  
  //ListView各个构造函数的共同参数  
  double? itemExtent,
  Widget? prototypeItem, //列表项原型，后面解释
  bool shrinkWrap = false,
  bool addAutomaticKeepAlives = true,
  bool addRepaintBoundaries = true,
  double? cacheExtent, // 预渲染区域长度
    
  //子widget列表
  List<Widget> children = const <Widget>[],
})
```

- `itemExtent`：该参数如果不为`null`，则会强制`children`的“长度”为`itemExtent`的值；这里的“长度”是指滚动方向上子组件的长度，也就是说如果滚动方向是垂直方向，则`itemExtent`代表子组件的高度；如果滚动方向为水平方向，则`itemExtent`就代表子组件的宽度。在`ListView`中，指定`itemExtent`比让子组件自己决定自身长度会有更好的性能，这是因为指定`itemExtent`后，滚动系统可以提前知道列表的长度，而无需每次构建子组件时都去再计算一下，尤其是在滚动位置频繁变化时（滚动系统需要频繁去计算列表高度）。
- `prototypeItem`：如果我们知道列表中的所有列表项长度都相同但不知道具体是多少，这时我们可以指定一个列表项，该列表项被称为 `prototypeItem`（列表项原型）。指定 `prototypeItem` 后，可滚动组件会在 layout 时计算一次它延主轴方向的长度，这样也就预先知道了所有列表项的延主轴方向的长度，所以和指定 `itemExtent` 一样，指定 `prototypeItem` 会有更好的性能。注意，`itemExtent` 和`prototypeItem` 互斥，不能同时指定它们。
- `shrinkWrap`：该属性表示是否根据子组件的总长度来设置`ListView`的长度，默认值为`false` 。默认情况下，`ListView`会在滚动方向尽可能多的占用空间。当`ListView`在一个无边界(滚动方向上)的容器中时，`shrinkWrap`必须为`true`。
- `addAutomaticKeepAlives`：该属性我们将在介绍 PageView 组件时详细解释。
- `addRepaintBoundaries`：该属性表示是否将列表项（子组件）包裹在`RepaintBoundary`组件中。`RepaintBoundary` 读者可以先简单理解为它是一个”绘制边界“，将列表项包裹在`RepaintBoundary`中可以避免列表项不必要的重绘，但是当列表项重绘的开销非常小（如一个颜色块，或者一个较短的文本）时，不添加`RepaintBoundary`反而会更高效（具体原因会在本书后面 Flutter 绘制原理相关章节中介绍）。如果列表项自身来维护是否需要添加绘制边界组件，则此参数应该指定为 false。

> 注意：上面这些参数并非`ListView`特有，在本章后面介绍的其他可滚动组件也可能会拥有这些参数，它们的含义是相同的。

默认构造函数有一个`children`参数，它接受一个Widget列表（List<Widget>）。这种方式适合只有少量的子组件数量已知且比较少的情况，反之则应该使用`ListView.builder` 按需动态构建列表项。

> 注意：虽然这种方式将所有`children`一次性传递给 ListView，但子组件）仍然是在需要时才会加载（build（如有）、布局、绘制），也就是说通过默认构造函数构建的 ListView 也是基于 Sliver 的列表懒加载模型。

eg:

```dart
ListView(
  shrinkWrap: true, 
  padding: const EdgeInsets.all(20.0),
  children: <Widget>[
    const Text('I\'m dedicating every day to you'),
    const Text('Domestic life was never quite my style'),
    const Text('When you smile, you knock me out, I fall apart'),
    const Text('And I thought I was so smart'),
  ],
);
```

#### ListView.builder

`ListView.builder`适合列表项比较多或者列表项不确定的情况

```dart
ListView.builder({
  // ListView公共参数已省略  
  ...
  required IndexedWidgetBuilder itemBuilder,
  int itemCount,
  ...
})

```

- `itemBuilder`：它是列表项的构建器，类型为`IndexedWidgetBuilder`，返回值为一个widget。当列表滚动到具体的`index`位置时，会调用该构建器构建列表项。
- `itemCount`：列表项的数量，如果为`null`，则为无限列表。

eg:

```dart
ListView.builder(
  itemCount: 100,
  itemExtent: 50.0, //强制高度为50.0
  itemBuilder: (BuildContext context, int index) {
    return ListTile(title: Text("$index"));
  }
);
```

![image-20260213214822115](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260213214822115.png)

#### ListView.separated

`ListView.separated`可以在生成的列表项之间添加一个分割组件，它比`ListView.builder`多了一个`separatorBuilder`参数，该参数是一个分割组件生成器。

下面我们看一个例子：奇数行添加一条蓝色下划线，偶数行添加一条绿色下划线。

```dart
class ListView3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //下划线widget预定义以供复用。  
    Widget divider1=Divider(color: Colors.blue,);
    Widget divider2=Divider(color: Colors.green);
    return ListView.separated(
      itemCount: 100,
      //列表项构造器
      itemBuilder: (BuildContext context, int index) {
        return ListTile(title: Text("$index"));
      },
      //分割器构造器
      separatorBuilder: (BuildContext context, int index) {
        return index%2==0?divider1:divider2;
      },
    );
  }
}
```

![image-20260213214915179](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260213214915179.png)

####无限加载列表

从数据源异步分批拉取一些数据，然后用`ListView`展示，当我们滑动到列表末尾时，判断是否需要再去拉取数据，如果是，则去拉取，拉取过程中在表尾显示一个loading，拉取成功后将数据插入列表；如果不需要再去拉取，则在表尾提示"没有更多"。

####添加固列表头

![image-20260213220305727](C:\Users\ClusteRain\AppData\Roaming\Typora\typora-user-images\image-20260213220305727.png)

```dart
@override
Widget build(BuildContext context) {
  return Column(children: <Widget>[
    ListTile(title:Text("商品列表")),
    Expanded(
      child: ListView.builder(itemBuilder: (BuildContext context, int index) {
        return ListTile(title: Text("$index"));
      }),
    ),
  ]);
}
```

### 控制和滚动监听

#### Scrollbar

**`ListView.builder`：** 它是一个**功能性组件**。它负责列表项的布局、懒加载（Sliver 机制）以及处理手指滑动的物理碰撞。但它**本身不包含**那个长条形的指示器（进度条）。

**`Scrollbar`：** 它是一个**视觉装饰组件**。它的唯一作用就是在子组件（必须是可滚动的）旁边画出那个代表当前位置的“滑块”。

#### ScrollController

`ScrollController`构造函数

```dart
ScrollController({
  double initialScrollOffset = 0.0, //初始滚动位置
  this.keepScrollOffset = true,//是否保存滚动位置
  ...
})
```

- `offset`：可滚动组件当前的滚动位置。
- `jumpTo(double offset)`、`animateTo(double offset,...)`：这两个方法用于跳转到指定的位置，它们不同之处在于，后者在跳转时会执行一个动画，而前者不会。

#####PageStorageKey

`PageStorage`是一个用于保存页面(路由)相关数据的组件,它拥有一个存储桶（bucket），子树中的Widget可以通过指定不同的`PageStorageKey`来存储各自的数据或状态。

每次滚动结束，可滚动组件都会将滚动位置`offset`存储到`PageStorage`中，当可滚动组件重新创建时再恢复。如果`ScrollController.keepScrollOffset`为`false`，则滚动位置将不会被存储，可滚动组件重新创建时会使用`ScrollController.initialScrollOffset`；`ScrollController.keepScrollOffset`为`true`时，可滚动组件在**第一次**创建时，会滚动到`initialScrollOffset`处

```dart
ListView(key: PageStorageKey(1), ... );
...
ListView(key: PageStorageKey(2), ... );
```

不同的`PageStorageKey`，需要不同的值，这样才可以为不同可滚动组件保存其滚动位置。

> 只有当Widget发生结构变化，导致可滚动组件的State销毁或重新构建时才会丢失状态，这种情况就需要显式指定`PageStorageKey`，通过`PageStorage`来存储滚动位置，一个典型的场景是在使用`TabBarView`时，在Tab发生切换时，Tab页中的可滚动组件的State就会销毁，这时如果想恢复滚动位置就需要指定`PageStorageKey`

#####ScrollPosition

ScrollPosition是用来保存可滚动组件的滚动位置的。一个`ScrollController`对象可以同时被多个可滚动组件使用，`ScrollController`会为每一个可滚动组件创建一个`ScrollPosition`对象，这些`ScrollPosition`保存在`ScrollController`的`positions`属性中（`List<ScrollPosition>`）。`ScrollPosition`是真正保存滑动位置信息的对象，`offset`只是一个便捷属性：

```dart
double get offset => position.pixels;
```

一个`ScrollController`虽然可以对应多个可滚动组件，但是有一些操作，如读取滚动位置`offset`，则需要一对一！但是我们仍然可以在一对多的情况下，通过其他方法读取滚动位置，举个例子，假设一个`ScrollController`同时被两个可滚动组件使用，那么我们可以通过如下方式分别读取他们的滚动位置：

```dart
...
controller.positions.elementAt(0).pixels
controller.positions.elementAt(1).pixels
...    
```

我们可以通过`controller.positions.length`来确定`controller`被几个可滚动组件使用。

ScrollPosition的方法

`ScrollPosition`有两个常用方法：`animateTo()` 和 `jumpTo()`，它们是真正来控制跳转滚动位置的方法，`ScrollController`的这两个同名方法，内部最终都会调用`ScrollPosition`的。

##### ScrollController控制原理

```dart
ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition oldPosition);
void attach(ScrollPosition position) ;
void detach(ScrollPosition position) ;
```

当`ScrollController`和可滚动组件关联时，可滚动组件首先会调用`ScrollController`的`createScrollPosition()`方法来创建一个`ScrollPosition`来存储滚动位置信息，接着，可滚动组件会调用`attach()`方法，将创建的`ScrollPosition`添加到`ScrollController`的`positions`属性中，这一步称为“注册位置”，只有注册后`animateTo()` 和 `jumpTo()`才可以被调用。

当可滚动组件销毁时，会调用`ScrollController`的`detach()`方法，将其`ScrollPosition`对象从`ScrollController`的`positions`属性中移除，这一步称为“注销位置”，注销后`animateTo()` 和 `jumpTo()` 将不能再被调用。

需要注意的是，`ScrollController`的`animateTo()` 和 `jumpTo()`内部会调用所有`ScrollPosition`的`animateTo()` 和 `jumpTo()`，以实现所有和该`ScrollController`关联的可滚动组件都滚动到指定的位置。

#### 滚动监听

#####1. 滚动通知

Flutter Widget树中子Widget可以通过发送通知（Notification）与父(包括祖先)Widget通信。父级组件可以通过`NotificationListener`组件来监听自己关注的通知，这种通信方式类似于Web开发中浏览器的事件冒泡，我们在Flutter中沿用“冒泡”这个术语，关于通知冒泡我们将在后面“事件处理与通知”一章中详细介绍。

可滚动组件在滚动时会发送`ScrollNotification`类型的通知，`ScrollBar`正是通过监听滚动通知来实现的。通过`NotificationListener`监听滚动事件和通过`ScrollController`有两个主要的不同：

1. NotificationListener可以在可滚动组件到widget树根之间任意位置监听。而`ScrollController`只能和具体的可滚动组件关联后才可以。
2. 收到滚动事件后获得的信息不同；`NotificationListener`在收到滚动事件时，通知中会携带当前滚动位置和ViewPort的一些信息，而`ScrollController`只能获取当前滚动位置。

实例在`scroll_notification_test_route.dart`

在接收到滚动事件时，参数类型为`ScrollNotification`，它包括一个`metrics`属性，它的类型是`ScrollMetrics`，该属性包含当前ViewPort及滚动位置等信息：

- `pixels`：当前滚动位置。
- `maxScrollExtent`：最大可滚动长度。
- `extentBefore`：滑出ViewPort顶部的长度；此示例中相当于顶部滑出屏幕上方的列表长度。
- `extentInside`：ViewPort内部长度；此示例中屏幕显示的列表部分的长度。
- `extentAfter`：列表中未滑入ViewPort部分的长度；此示例中列表底部未显示到屏幕范围部分的长度。
- `atEdge`：是否滑到了可滚动组件的边界（此示例中相当于列表顶或底部）。

###AnimatedList

AnimatedList 和 ListView 的功能大体相似，不同的是， AnimatedList 可以在列表中插入或删除节点时执行一个动画，在需要添加或删除列表项的场景中会提高用户体验。

AnimatedList 是一个 StatefulWidget，它对应的 State 类型为 AnimatedListState，添加和删除元素的方法位于 AnimatedListState 中：

```dart
void insertItem(int index, { Duration duration = _kDuration });

void removeItem(int index, AnimatedListRemovedItemBuilder builder, { Duration duration = _kDuration }) ;
```

### GridView 网格布局

```dart
GridView({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    required this.gridDelegate,  //下面解释
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    double? cacheExtent, 
    List<Widget> children = const <Widget>[],
    ...
  })
```

`gridDelegate`参数，类型是`SliverGridDelegate`，它的作用是控制`GridView`子组件如何排列(layout)。

`SliverGridDelegate`是一个抽象类，定义了`GridView` Layout相关接口，子类需要通过实现它们来实现具体的布局算法。Flutter中提供了两个`SliverGridDelegate`的子类`SliverGridDelegateWithFixedCrossAxisCount`和`SliverGridDelegateWithMaxCrossAxisExtent`，我们可以直接使用

####SliverGridDelegateWithFixedCrossAxisCount

```dart
SliverGridDelegateWithFixedCrossAxisCount({
  @required double crossAxisCount, 
  double mainAxisSpacing = 0.0,
  double crossAxisSpacing = 0.0,
  double childAspectRatio = 1.0,
})
```

- `crossAxisCount`：横轴子元素的数量。此属性值确定后子元素在横轴的长度就确定了，即ViewPort横轴长度除以`crossAxisCount`的商。
- `mainAxisSpacing`：主轴方向的间距。
- `crossAxisSpacing`：横轴方向子元素的间距。
- `childAspectRatio`：子元素在横轴长度和主轴长度的比例。由于`crossAxisCount`指定后，子元素横轴长度就确定了，然后通过此参数值就可以确定子元素在主轴的长度。

可以发现，子元素的大小是通过`crossAxisCount`和`childAspectRatio`两个参数共同决定的。注意，这里的子元素指的是子组件的最大显示空间，注意确保子组件的实际大小不要超出子元素的空间。

#### SliverGridDelegateWithMaxCrossAxisExtent

该子类实现了一个横轴子元素为固定最大长度的layout算法

```dart
SliverGridDelegateWithMaxCrossAxisExtent({
  double maxCrossAxisExtent,
  double mainAxisSpacing = 0.0,
  double crossAxisSpacing = 0.0,
  double childAspectRatio = 1.0,
})
```

`maxCrossAxisExtent`为子元素在横轴上的最大长度，之所以是“最大”长度，是**因为横轴方向每个子元素的长度仍然是等分的**，举个例子，如果ViewPort的横轴长度是450，那么当`maxCrossAxisExtent`的值在区间[450/4，450/3)内的话，子元素最终实际长度都为112.5，而`childAspectRatio`所指的子元素横轴和主轴的长度比为**最终的长度比**。其他参数和`SliverGridDelegateWithFixedCrossAxisCount`相同。

####GridView.count

`GridView.count`构造函数内部使用了`SliverGridDelegateWithFixedCrossAxisCount`，我们通过它可以快速的创建横轴固定数量子元素的`GridView`，我们可以通过以下代码实现和上面例子相同的效果等：

```dart
GridView.count( 
  crossAxisCount: 3,
  childAspectRatio: 1.0,
  children: <Widget>[
    Icon(Icons.ac_unit),
    Icon(Icons.airport_shuttle),
    Icon(Icons.all_inclusive),
    Icon(Icons.beach_access),
    Icon(Icons.cake),
    Icon(Icons.free_breakfast),
  ],
);
```

#### GridView.extent

GridView.extent构造函数内部使用了SliverGridDelegateWithMaxCrossAxisExtent，我们通过它可以快速的创建横轴子元素为固定最大长度的GridView，上面的示例代码等价于：

```dart
GridView.extent(
   maxCrossAxisExtent: 120.0,
   childAspectRatio: 2.0,
   children: <Widget>[
     Icon(Icons.ac_unit),
     Icon(Icons.airport_shuttle),
     Icon(Icons.all_inclusive),
     Icon(Icons.beach_access),
     Icon(Icons.cake),
     Icon(Icons.free_breakfast),
   ],
 );
```

#### GridView.builder

当子widget比较多时，我们可以通过`GridView.builder`来动态创建子widget。`GridView.builder` 必须指定的参数有两个：

```dart
GridView.builder(
 ...
 required SliverGridDelegate gridDelegate, 
 required IndexedWidgetBuilder itemBuilder,
)
```

其中`itemBuilder`为子widget构建器。

 