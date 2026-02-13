##随记

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