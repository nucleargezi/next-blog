#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "SAM",
  desc: [后缀自动机总结],
  date: "2026-06-20",
  tags: ("alg", "SAM"),
  toc: true,
)

= SAM - 从入门到入土

== 鲜花

早在两个赛季前我就学会了 SAM, 但没学明白, 在接下来的两年内我不断增进对 SAM 的理解, 现在终于能写一份总结性的博客来展示一下我的思考

SAM 本身的结构相当复杂, 初学者很难学明白, 甚至可能因此直接被劝退, 本文作为一个教学向的文章, 对相关概念进行了简化甚至省略, 目的在于让读者快速掌握 SAM 的使用, 来用它解决问题

本文默认读者知道什么是自动机

== 概念

所谓 "后缀自动机 Suffix Automaton", 单看名字可能不太直观. 它本质上是一个高度压缩地维护字符串所有子串信息的结构

=== 子串等价类

SAM 的每个非根节点都表示一个*子串等价类*, 根节点可以看作表示空串, 如果两个子串在原串中的出现结束位置集合完全相同, 它们就属于一个等价类

每个等价类会记录其中最长子串的长度, 下文会记作 `sz` , 一个等价类中的所有子串都是这个最长子串的后缀, 且它们的长度构成一个连续区间. 例如某个等价类的最长串是 "abcdefg", 最短串是 "fg", 那么 "fg", "efg", ..., "abcdefg" 都属于这个等价类

所有非空子串会被 SAM 的非根节点不重不漏地划分到这些等价类中, 因此 SAM 可以用大约 $2n$ 个节点高度压缩地维护所有子串信息.

=== Parent Tree

子串等价类之间形成了一个树形结构, 称为 Parent Tree, 也就是 Suffix Link Tree

对于一个等价类 n, 它的父亲 fa[n] 表示: 从 n 的最长串不断删去前面的字符, 得到的第一个不属于 n 的后缀所在的等价类. 因此 Parent Tree 描述的是等价类之间后缀缩短的关系, 如果用每个等价类的最长代表串标注节点, 例如字符串 abcabc 的 Parent Tree 大致如下:

```
""
├── "a"
│   └── "abca"
├── "ab"
│   └── "abcab"
└── "abc"
    └── "abcabc"
```

令 sz[n] 为等价类 n 的最长串的长度, 那么这个等价类表示的子串的长度范围就是 $["sz"["fa"[n]] + 1, "sz"[n]]$, 所以等价类 n 中本质不同子串的数量就是 $"sz"[n] - "sz"["fa"[n]]$

由于 Parent Tree 描述后缀关系, 任意两个等价类 $a, b$ 的 LCA 对应它们最长代表串的 LCS(最长公共后缀) 所在等价类, 如果这 $a, b$ 是两个前缀的终止状态, 那么 $"sz"["lca"(a, b)]$ 就是两个前缀的 LCS 长度

=== 后缀自动机

自动机转移描述的是“在当前匹配串右侧追加一个字符后会进入哪个等价类”, 而 Parent Tree 边描述的是“不断删除左侧字符, 也就是缩短后缀时会跳到哪个等价类”.

SAM 的构建过程可以理解为: 每次新增字符, 就加入了一个新的前缀. 这个前缀的所有后缀, 也就是以当前位置结尾的所有子串, 会被归入对应的子串等价类中. 构建过程同时维护自动机转移和 Parent Tree 边, 这里不展开具体过程和证明

== 应用

需要的前置概念只有这些, 现在展示如何利用这些性质解题

=== P2408

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P2408", "Link")

==== Formal Problem Statement

求一个字符串的本质不同子串数量

==== Constraints

- $|S| <= 10^5$

==== Solution

题目是从最基础的讲起, 这里只利用 SAM 节点的基本性质和 Parent Tree

自动机的每个节点都是一个子串等价类, 每个节点等价类里的串都是其最长串的连续后缀, 令一个节点在 Parent Tree 上父节点的 sz 为 c, 该节点的 sz 为 d, 那么这个等价类包含的子串长度就在 $[c + 1, d]$ 中, 也就是有 $d - c$  个本质不同子串

而所有节点不重不漏地包含了所有子串, 加起来就是答案

==== Implementation
```cpp
void Yorisou() {
  INT(N);
  STR(s);
  for (char &c : s) c -= 'a';
  sam ss(si(s));
  ss.build(s);
  ll rs = 0;
  FOR(i, 1, si(ss)) rs += ss[i].sz - ss[ss[i].fa].sz;
  print(rs);
}
```

=== P5341

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P5341", "Link")

==== Formal Problem Statement

求字符串子串长度出现次数最多的长度数

==== Constraints

- $|S| <= 10^5$

==== Solution

扯一下子串数量和 SAM 的关系, SAM 构造时每加入一个字符, 就相当于加入了一个新的前缀. 这个前缀的所有后缀正好对应以当前位置结尾的所有子串, 每个不同子串都会被归入某个子串等价类, 也就是 SAM 的一个状态中 

为了统计每个等价类中的子串在原串中出现了多少次, 可以在每次加入字符后, 给当前前缀对应的终止状态加一计数. 在 Parent Tree 上, 一个状态的祖先表示它的后缀等价类, 将计数按 sz 从大到小向父节点累加, 即可得到每个状态的出现次数

这样就求出了每个等价类, 也就是某一段长度的子串在串中出现的次数, 可以直接统计答案

==== Implementation

```cpp
void Yorisou() {
  STR(s);
  INT(K);
  for (char &c : s) c -= 'a';
  sam ss(si(s));
  vc<int> sz = ss.build(s);
  int N = si(s), M = si(ss);
  vc<ll> c(N + 2);
  FOR(n, 1, M) if (sz[n] == K) {
    int l = ss[ss[n].fa].sz + 1, r = ss[n].sz + 1;
    c[l] += 1, c[r] -= 1;
  }
  FOR(i, N + 1) c[i + 1] += c[i];
  int mx = 0, rs = -1;
  FOR_R(i, N + 1) if (chmax(mx, c[i])) rs = i;
  print(rs);
}
```

=== P4248

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P4248", "Link")

==== Formal Problem Statement

给定一个长度为 $n$ 的字符串 $S$.

对于每个 $1 <= i <= n$, 记 $T_i$ 表示从 $S$ 的第 $i$ 个字符开始的后缀

$
  T_i = S_i S_(i + 1) dots S_n
$

现在要求计算如下式子的值:

$
  sum_(1 <= i < j <= n) (
    "len"(T_i) + "len"(T_j) - 2 "lcp"(T_i, T_j)
  )
$

其中, $"len"(a)$ 表示字符串 $a$ 的长度, $"lcp"(a, b)$ 表示字符串 $a$ 与字符串 $b$ 的最长公共前缀长度.

==== Constraints

- $2 <= n <= 5 * 10^5$

==== Solution

将 $"len"(T_i)$ 这种不变的东西提出, 原式中只有 $sum_(1 <= i < j <= n) ("lcp"(T_i, T_j))$

就是要求所有 Suffix 的 LCP; 将字符串翻转, 反串的 Prefix 就是原串的 Suffix, 反串中一对 Suffix 的 LCP 就是原串一对 Prefix 的 LCS, 而 Parent Tree 上两个前缀串所在节点的 LCA 的 sz 就是这两个 Prefix 的 LCP

所以转化为求所有前缀所在状态两两在 Parent Tree 上 LCA 的 sz 之和, 对每个节点, 统计以它为 LCA, 跨越它产生的贡献即可

==== Implementation
```cpp
void Yorisou() {
  STR(s);
  reverse(s);
  for (char &c : s) c -= 'a';
  sam ss;
  Z [sz, V] = ss.slv(s);
  int N = si(s);
  ll rs = ll(N - 1) * N * (N + 1) / 2;
  reverse(V);
  pop(V);
  vc<int> f(si(ss));
  for (int x : ss.en) f[x] = 1;
  for (int n : V) {
    int fa = ss[n].fa;
    rs -= ll(sz[n]) * f[fa] * ss[fa].sz * 2;
    f[fa] += sz[n];
  }
  print(rs);
}
```

=== P5108

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P5108", "Link")

==== Formal Problem Statement

求一个字符串长度为 i 的子串中, 字典序最小的, 左端点最小的左端点的值

==== Constraints

$1 <= n <= 3 * 10^5$

==== Solution

SAM 在构建时不断加入当前前缀, 天然容易某个子串作为后缀的右端点信息; 要求字典序最小子串的最小左端点, 可以对反串建立 SAM, 原串中的左端点在反串中会变成对应反向子串的右端点, 于是可以通过反串的 Parent Tree 向上传递, 得到每个状态对应子串在原串中的最小左端点

在 Parent Tree 上, 对每个节点的儿子按照其对应原串子串在当前公共前缀之后的下一字符排序, 再进行 dfs, 即可按字典序枚举这些等价类. 对于每个第一次访问到的状态, 用它更新其长度区间的答案. 可以用并查集维护下一个未被更新的位置, 跳过已经计算的

这题值域比较大, 需要在 SAM 内用 map 存自动机边

==== Implementation
```cpp
void Yorisou() {
  INT(sig, N);
  vc<int> s(N);
  if (sig != 26) {
    IN(s);
  } else {
    STR(str);
    FOR(i, N) s[i] = str[i] - 'a';
  }
  sam_map ss(N);
  reverse(s);
  vc<int> V = ss.slv(s).se;
  reverse(s);
  int M = si(ss);

  vc<int> mn(M, inf<int>);
  FOR(i, N) chmin(mn[ss.en[i]], N - i - 1);
  FOR_R(i, 1, M) {
    int n = V[i];
    chmin(mn[ss[n].fa], mn[n]);
  }
  vc<vc<int>> g(M);
  FOR(i, 1, M) g[ss[i].fa].ep(i);

  FOR(n, M) {
    sort(g[n], [&](int a, int b) {
      int l = s[mn[a] + ss[n].sz], r = s[mn[b] + ss[n].sz];
      return l == r ? mn[a] < mn[b] : l < r;
    });
  }
  vc<int> rs(N);
  nxt_dsu f(N + 1);
  vc<PII> st;
  FOR_R(i, si(g[0])) st.ep(0, g[0][i]);
  while (si(st)) {
    Z [p, n] = pop(st);
    int l = ss[p].sz + 1, r = ss[n].sz;
    for (int k = f[l]; k <= r; k = f[k]) {
      rs[k - 1] = mn[n] + 1;
      f.del(k);
    }
    FOR_R(i, si(g[n])) st.ep(n, g[n][i]);
  }
  print(rs);
}
```

=== P7409

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P7409", "Link")

==== Formal Problem Statement

对一个字符串多次询问, 每次给出若干个后缀, 求所有后缀两两之间的 LCP 长度之和

==== Constraints

- $|S| <= 5 * 10^5$
- $sum "len"(q_i) <= 3 * 10^6$

==== Solution

像前面的题一样将字符串翻转, 问题变为求指定反串前缀两两间的 LCS 之和, 还是同样的 dp 方法, 只是需要在虚树上进行

==== Implementation
```cpp
void Yorisou() {
  INT(N, Q);
  STR(s);
  FOR(i, N) s[i] -= 'a';
  reverse(s);
  sam ss(N);
  ss.build(s);
  vc<vc<int>> g(ss.build_dir_g());
  tr v(g, 0);
  fast_lca fs(v);

  vc<PII> es;
  vc<int> c(si(ss));
  FOR(Q) {
    INT(n);
    VEC(int, a, n);
    unique(a);
    for (int &x : a) ++c[x = ss.en[N - x]];
    fs.tree_compress(a, es);
    ll rs = 0;
    reverse(es);
    for (var [fi, ti] : es) {
      int n = a[fi], p = a[ti];
      rs += ll(c[p]) * c[n] * ss[p].sz;
      c[p] += c[n];
    }
    for (int x : a) c[x] = 0;
    print(rs);
  }
}
```

=== P11305

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P11305", "Link")

==== Formal Problem Statement

给定字符串 s, 令 s(l, r), 为 s[l, r] , t(l, r) 为 s 删去 s(l, r) 剩下的部分拼接而成的串, 找出一个最长的区间 [l, r] , 使得 s(l, r) 在 t(l, r) 中作为子串出现

==== Constraints

- $|S| <= 10^5$

==== Solution

t(l, r) 由原串的一对不交前缀后缀组成, 所以答案分为两种
+ s(l, r) 在前缀或后缀中作为一个完整串出现
+ s(l, r) 在拼接处产生

最后就是在两类中取 max

对于第一类答案, 我们知道在 SAM 构建过程中每次加入新字符, 到达的状态就是对应前缀所在等价类, 以相同右端点结束的所有子串都在这个等价类到根的链上, 所以可以自下而上统计每个等价类中最靠左的子串和最靠右的子串, 如果他们不重, 就可能成为答案

对于第二类, 分割处两侧拼出了分割出去的 s(l, r), 这说明它一定可以描述为一个形如 A[AB]B 的结构, [AB] 就是被分割出去的 s(l, r)

现在问题变为了求字符串中最长的 AABB 状串, 这个可以用 runs 秒掉, 我是这样做的; 也可以用 SA 解决, 不过我没有去思考这个做法

==== Implementation
```cpp
void Yorisou() {
  STR(s);
  int N = si(s);
  for (char &c : s) c -= 'a';
  
  sam ss(si(s));
  vc<int> V = ss.slv(s).se, en = std::move(ss.en);
  int M = si(ss);
  vc<PII> dp(M, {M, -1});
  FOR(i, N) dp[en[i]] = {i, i};
  reverse(V);
  pop(V);
  int rs = 0;
  for (int n : V) {
    var [l, r] = dp[n];
    int sz = ss[n].sz;
    if (l + sz <= r) chmax(rs, sz);
    int p = ss[n].fa;
    chmin(dp[p].fi, l);
    chmax(dp[p].se, r);
  }

  seg_dual_t<Max<int>> L(N), R(L);
  for (Z [l, r ,p] : runs(s)) {
    int sz = r - l;
    for (int k = 1; 2 * k * p <= sz; ++k) {
      int sq = 2 * k * p;
      L.apply(l + sq - 1, r, sq);
      R.apply(l, r - sq + 1, sq);
    }
  }
  FOR(i, 1, N) chmax(rs, (L[i - 1] + R[i]) / 2);
  print(rs);
}
```

=== P3002

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P3002", "Link")

==== Formal Problem Statement

给出串 s, t, 问最少能将 t 分割成几段, 使得每段都是 s 的子串

==== Constraints

- $|S| <= 5 * 10^4$ 

==== Solution

从这里开始的题目, 需要使用到 SAM 的自动机本身

其实这个范围比较水, 解法是 On 的

后缀自动机是自动机, 它当然可以用于匹配, 拿一个字符串在自动机上跑, 无法匹配了就说明这个串不是子串, 匹配到了的最终状态就是其作为子串所在的等价类, 等价类出现次数也就是它作为子串的出现次数;

如果允许失配回退, 那么每次匹配到达的状态的 sz 就是以当前字符为结尾能匹配的最长子串长度

所以这题只要一直匹配, 失配返回 0 即可, 失配次数 + 1 就是答案

==== Implementation
```cpp
void Yorisou() {
  INT(N, M);
  string s, t;
  for (string x; cin >> x; ) {
    for (char c : x) {
      c -= 'A';
      (si(s) < N ? s : t) += c;
    }
  }

  sam ss(N);
  ss.build(s);
  int rs = 1;
  for (int x = 0; int c : t) {
    x = ss[x][c];
    if (x == -1) ++rs, x = ss[0][c];
  }
  print(rs);
}
```

=== P3181

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P3181", "Link")

==== Formal Problem Statement

给定两个字符串 s, t, 求有多少对区间 $[l_1, r_1]$, $[l_2, r_2]$, 满足 $s[l_1 ... r_1] = t[l_2 ... r_2]$.

==== Constraints

- $|S| <= 2 * 10^5$

==== Solution

上一题讲了, 通过在 s 的 SAM 上对 t 匹配, 可以知道以 t 的每个位置结尾, 能匹配到的 s 最长子串, 这个子串的所有后缀都会贡献它在 s 中出现的次数, 也就是对应 s 的 Parent Tree 这个点到根的整条链都能产生贡献

因此需要预处理 dp[n] 表示等价类 n 的最长串所在的后缀在 A 中出现次数之和, 转移为:

`dp[n] = dp[fa[n]] + cnt[n] * (sz[n] - sz[fa[n]])`

在匹配中, 设当前匹配到等价类 n, 匹配长度 len, 由于 len 可能小于 sz[n], 这个等价类产生的贡献不完整, 需要特判一下

对 t 每个位置匹配到的贡献求和就是答案

==== Implementation
```cpp
void Yorisou() {
  STR(a, b);
  for (char &c : a) c -= 'a';
  for (char &c : b) c -= 'a';
  sam ss;
  Z [cnt, V] = ss.slv(a);
  vc<ll> dp(si(cnt));
  for (int n : V) if (n) {
    int f = ss[n].fa;
    dp[n] += cnt[n] * (ss[n].sz - ss[f].sz) + dp[f];
  }
  ll s = 0;
  for (int x = 0, sz = 0; int c : b) {
    while (x and ss[x][c] == -1) x = ss[x].fa, sz = ss[x].sz;
    if (ss[x][c] != -1) x = ss[x][c], ++sz;
    s += dp[x] + ll(cnt[x]) * (sz - ss[x].sz);
  }
  print(s);
}
```

=== P4112

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P4112", "Link")

==== Formal Problem Statement

给定串 s, t, 分别计算四种串的最短串长度:
+ 是 s 子串不是 t 子串
+ 是 s 子串不是 t 子序列
+ 是 s 子序列不是 t 子串
+ 是 s 自诩类不是 t 子序列

==== Constraints

- $|s|, |t| <= 2000$

==== Solution

建出 SAM 和 子序列自动机, 在两个自动机上按题目条件跑匹配

==== Implementation
```cpp
void Yorisou() {
  STR(s, t);
  int N = si(s), M = si(t);
  for (char &c : s) c -= 'a';
  for (char &c : t) c -= 'a';
  sam ss(si(t));
  ss.build(t);
  Z nx = subseq_next(t);
  int sz = si(ss);

  Z slv0 = [&](Z &nx, bool o) {
    int rs = inf<int>;
    FOR(l, N) {
      int x = 0;
      FOR(r, l, N) {
        int c = s[r];
        if (nx[x][c] == -1) {
          chmin(rs, r - l + 1);
          break;
        }
        x = nx[x][c] + o;
      }
    }
    print(rs == inf<int> ? -1 : rs);
  };
  slv0(ss, 0);
  slv0(nx, 1);

  Z slv1 = [&](Z &nx, bool o) {
    int le = o ? M + 1 : sz;
    vc<int> dp(le, inf<int>), ndp(dp);
    FOR_R(i, N) {
      ndp = dp;
      int c = s[i];
      FOR(x, le) {
        int y = nx[x][c];
        int ii = y == -1 ? 1 : (dp[y + o] == inf<int> ? inf<int> : dp[y + o] + 1);
        chmin(ndp[x], ii);
      }
      dp.swap(ndp);
    }
    int rs = dp[0];
    print(rs == inf<int> ? -1 : rs);
  };
  slv1(ss, 0);
  slv1(nx, 1);
}
```

=== P5212

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P5212", "Link")

==== Formal Problem Statement

给定初始字符串, 需要支持两种操作:
+ 在当前串末尾追加一个字符串
+ 询问一个串 s 在当前串中作为子串出现了几次

*强制在线*

==== Constraints

+ $|"init"|, |sum s| <= 6 * 10^5$
+ $q <= 6 * 10^5$

==== Solution

如果没有修改, 相当于要求查询串在 SAM 中匹配到的最终状态的出现次数, 也就是 Parent Tree 上该节点的子树权值和(原串前缀终止状态在子树中的出现次数), 是个简单的子树权值查询

在 SAM 追加字符的过程中, 自动机和 Parent Tree 的状态在不断改变, 所以对于这题而言就是一个动态树子树和问题, 在 Parent Tree 修改的同时也用一个 LCT 进行相同的修改即可

LCT 维护子树和需要维护虚儿子信息, 这里不展开

==== Implementation
```cpp
void Yorisou() {
  INT(Q);
  sam_lct ss(2'000'000);
  STR(s);
  for (char &c : s) c -= 'A';
  int x = 0;
  for (int c : s) x = ss.add(x, c);

  int rs = 0;
  FOR(Q) {
    STR(op, s);
    int n = si(s), k = rs;
    for (char &c : s) c -= 'A';
    FOR(i, n) k = (k * 131 + i) % n, swap(s[i], s[k]);
    if (op[0] == 'A') {
      for (int c : s) x = ss.add(x, c);
    } else {
      int c = ss.count(s);
      print(c);
      rs ^= c;
    }
  }
}
```

=== P12729

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P12729", "Link")

==== Formal Problem Statement

给定两个括号串 A, B, 求满足以下条件的最长括号串长度
+ 是 A 的子串
+ 是 B 的子串
+ 是合法括号序列

==== Constraints

- $|A|, |B| <= 5 * 10^5$

==== Solution

问题可以拆解成两部分

首先用 A 建立 SAM, 用 B 在 SAM 上跑匹配, 求出 B 的每个位置为结尾能匹配的最长子串长度 len , 这样对于每个结尾 i, 实际上提供了一个合法区间 [i - len + 1, i] 这个区间内的所有子串都同时是 A 和 B 的子串, 其实到这里就做完了, 可以利用猫树查询任意区间内的最长合法括号串, 查 |B| 个区间即可

当然可以有不那么科技的统计方法, 大约是什么二维数点或者笛卡尔树之类的东西, 我没细想, 能贴板子就直接贴了

==== Implementation
```cpp
void Yorisou() {
  STR(a, b);
  range_brac ds(b);
  for (char &c : a) c = c == '(' ? 0 : 1;
  for (char &c : b) c = c == '(' ? 0 : 1;
  sam<2> ss(si(a));
  ss.build(a);
  vc<int> sl = ss.run(b);
  int n = si(b), rs = 0;
  FOR(i, n) chmax(rs, ds.prod(i - sl[i] + 1, i + 1));
  print(rs);
}
```

=== P3346

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P3346", "Link")

==== Formal Problem Statement

给定一个叶子节点不超过 20 个的树, 每个节点有一个字符, 求这棵树的树链形成了多少本质不同字符串

==== Constraints

- $n <= 10^5$

==== Solution

这里开始要用到广义后缀自动机, 同样不展开其原理和实现, 只需要知道它能插入多串, 和普通 SAM 一样用自动机和 Parent Tree 维护所有串的子串信息

以所有叶子为根搜一次, 每条根到叶子的字符串都插入广义 SAM 中, 然后和普通 SAM 一样统计本质不同子串

==== Implementation
```cpp
void Yorisou() {
  INT(N, K);
  sam_ex<10> ss;
  VEC(int, s, N);
  vc<vc<int>> g(N);
  FOR(N - 1) {
    INT(a, b);
    --a, --b;
    g[a].ep(b);
    g[b].ep(a);
  }

  vc<int> t;
  FOR(i, N) if (si(g[i]) == 1) t.ep(i);
  
  vc<int> fa(N, -1);
  Z f = [&](Z &f, int n, int p) -> void {
    fa[n] = p;
    int c = 0;
    for (int x : g[n]) if (x != p) f(f, x, n), ++c;
    if (c) return;
    vc<int> buf;
    while (n != -1) buf.ep(s[n]), n = fa[n];
    for (int x = 0; int c : buf) x = ss.add(x, c);
  };
  for (int x : t) f(f, x, -1);
  print(ss.count());
}
```

=== P4081

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P4081", "Link")

==== Formal Problem Statement

给定多个串, 求每个串有多少个本质不同子串不是其他所有串的子串

==== Constraints

- $N <= 10^5$

==== Solution

使用广义 SAM, 在插入字符串的时候记录一下每个状态被那些串的前缀到达, 对于出现串只有一种的等价类, 产生贡献并上传所有串, 否则不产生贡献且不上传, 统计贡献即可

==== Implementation
```cpp
void Yorisou() {
  INT(N);
  sam_ex ss;
  vc<vc<int>> v(4'000'00);
  FOR(i, N) {
    STR(s);
    for (int x = 0; int c : s) x = ss.add(x, c - 'a'), v[x].ep(i);
  }
  vc<vc<int>> g = ss.build_dir_g();
  vc<int> rs(N);
  Z f = [&](Z &f, int n) -> void {
    for (int x : g[n]) {
      f(f, x);
      for (int i = 0, sz = si(v[x]); i < sz and si(v[n]) < 2; ++i) {
        int w = v[x][i], ok = 1;
        for (int x : v[n]) ok &= x != w;
        if (ok) v[n].ep(w);
      }
    }
    if (n and si(v[n]) == 1) {
      int f = ss[n].fa;
      rs[v[n][0]] += ss[n].sz - ss[f].sz;
    }
  };
  f(f, 0);
  for (int x : rs) print(x);
}
```

=== P6139

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P6139", "Link")

==== Formal Problem Statement

板子题

==== Constraints

==== Solution

没什么好说的

==== Implementation
```cpp
void Yorisou() {
  INT(N);
  sam_ex ss;
  FOR(i, N) {
    STR(s);
    for (int x = 0; int c : s) x = ss.add(x, c - 'a');
  }
  print(ss.count());
  print(si(ss));
}
```

=== P2408

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P2408", "Link")

==== Formal Problem Statement

有两个长度为 n 的由小写字母组成的字符串 a,b, 取出他们所有长为 k 的子串, 这些子串分别组成集合 A,B. 现在要修改 A 中的串, 使得 A 和 B 完全相同. 可以任意次选择修改 A 中一个串的一段后缀, 花费为这段后缀的长度. 总花费为每次修改花费之和, 求总花费的最小值

==== Constraints

$1 <= k <= n <= 1.5 * 10^5$

==== Solution

对两个串的反串建立广义 SAM, 然后自下而上对它们的等价类用 LCP 合并, 无法合并的上传

==== Implementation
```cpp
void Yorisou() {
  INT(N, K);
  STR(s, t);
  for (char &c : s) c -= 'a';
  for (char &c : t) c -= 'a';
  reverse(s);
  reverse(t);
  
  sam_ex ss;
  vc<array<int, 2>> dp(N << 2);
  int x = 0;
  FOR(i, N) {
    x = ss.add(x, s[i]);
    if (i >= K - 1) ++dp[x][0];
  }
  x = 0;
  FOR(i, N) {
    x = ss.add(x, t[i]);
    if (i >= K - 1) ++dp[x][1];
  }
  vc<vc<int>> g(ss.build_dir_g());

  ll rs = 0;
  Z f = [&](Z &f, int n) -> void {
    for (int x : g[n]) f(f, x), dp[n][0] += dp[x][0], dp[n][1] += dp[x][1];
    int lcp = min(ss[n].sz, K), d = min(dp[n][0], dp[n][1]);
    rs += ll(K - lcp) * d;
    FOR(i, 2) dp[n][i] -= d;
  };
  f(f, 0);
  print(rs);
}
```

=== P9664

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P9664", "Link")

==== Formal Problem Statement

给定 n 个串, 连边代价为 LCS 长度, 求最大生成树

==== Constraints

$|s| <= 2 * 10^6$

==== Solution

建立广义 SAM, 要最大生成树就要合并的位置在 Parent Tree 上尽量靠下, 让 LCS 更长, 可以对等价类长度排个序, 从长到短合并, 无法合并就上传

==== Implementation
```cpp
void Yorisou() {
  INT(N);
  sam_ex ss;
  vc<vc<int>> v(4'000'010);
  FOR(i, N) {
    STR(s);
    for (int p = 0; int c : s) p = ss.add(p, c - 'a'), v[p].ep(i);
  }
  vc<int> I(si(ss) - 1);
  iota(all(I), 1);
  sort(I, [&](int i, int k) { return ss[i].sz > ss[k].sz; });

  vc<char> vis(N, 1);
  dsu fa(N);
  Z un = [&](vc<int> &a)  {
    int n = 0;
    for (int x : a) if (vis[x = fa[x]]) vis[a[n++] = x] = 0;
    a.resize(n);
    for (int x : a) vis[x] = 1;
  };

  ll s = 0;
  for (int n : I) {
    un(v[n]);
    int sz = si(v[n]);
    FOR(i, 1, sz) fa.merge(v[n][i - 1], v[n][i]);
    if (sz) s += ss[n].sz * ll(sz - 1), v[ss[n].fa].ep(v[n][0]);
  }
  print(s);
}
```

=== P16933

- Difficulty - #text(fill: purple)[*省选/NOI−*]
- #link("https://www.luogu.com.cn/problem/P16933", "Link")

==== Formal Problem Statement

给定字符串 $s$ 和整数 $k$, 选择某个字符串 $t$ 在 $s$ 中的 $k$ 个出现位置 $p_1 < p_2 < ... < p_k$, 最大化 
$k|t| - (p_k - p_1 + |t|)$

若最大值为负, 可选择不选, 答案为 $0$

==== Constraints

- $n <= 2 * 10^5$
- $1 <= k <= 40$

==== Solution

一些 SAM 题目涉及线段树合并, 以这题为例子大概讲讲

我们知道 SAM 每次追加字符就是在插入一个前缀, 相同结尾的子串信息存在了 插入后的终止状态在 Parent Tree 上的所有祖先中, 所以可以自下而上线段树合并来维护所有节点包含的前缀结尾, 利用这一点来处理一些和结束位置相关的子串信息

这题其实就是要维护每个等价类中排序后距离最近的连续 K 个结尾的距离, 这部分信息的合并需要前后缀信息, 所以要一起维护, 这里不展开了

另外这题需要卡常

==== Implementation
```cpp
int K;
struct MX {
  struct X {
    vc<int> l, r;
    int s;
  };

  static X op(const X &a, const X &b) {
    X c;
    c.s = min(a.s, b.s);

    int nl = min(K, int(a.l.size() + b.l.size()));
    c.l.reserve(nl);
    for (int x : a.l) {
      c.l.ep(x);
      if (si(c.l) == K) break;
    }
    if (si(c.l) < K) {
      for (int x : b.l) {
        c.l.ep(x);
        if (si(c.l) == K) break;
      }
    }

    int nr = min(K, int(a.r.size() + b.r.size()));
    c.r.reserve(nr);
    for (int x : b.r) {
      c.r.ep(x);
      if (si(c.r) == K) break;
    }
    if (si(c.r) < K) {
      for (int x : a.r) {
        c.r.ep(x);
        if (si(c.r) == K) break;
      }
    }
    int n = si(a.r), m = si(b.l);
    int L = max(1, K - m), R = min(K - 1, n);
    FOR(i, L, R + 1) {
      int rs = K - i, l = a.r[i - 1], r = b.l[rs - 1];
      chmin(c.s, r - l);
    }
    return c;
  }

  static X unit() {
    return {{}, {}, inf<int>};
  }

  static X sing(int i) {
    X c = unit();
    c.l.ep(i);
    c.r.ep(i);
    return c;
  }
  
  static constexpr bool commute = 0;
};

using DS = segd_t<MX, 0, int, 20>;
using np = DS::np;
void Yorisou() {
  INT(N);
  IN(K);
  STR(s);
  if (K == 1) return print(0);
  FOR(i, N) s[i] -= 'a';
  int sz;
  Z [en, le, fa, V] = [&]() {
    sam ss;
    ss.build(s);
    sz = si(ss);
    vc<int> le(sz), fa(sz), V;
    FOR(i, 1, sz) le[i] = ss[i].sz;
    FOR(i, 1, sz) fa[i] = ss[i].fa;
    vc<vc<int>> g = ss.build_dir_g();
    Z f = [&](Z &f, int n) -> void {
      if (n) V.ep(n);
      for (int x : g[n]) f(f, x);
    };
    f(f, 0);
    return tuple{ss.en, le, fa, V};
  }();

  DS seg(0, N);
  vc<np> t(sz);
  FOR(i, N) {
    np &x = t[en[i]];
    x = seg.set(x, i, MX::sing(i));
  }
  int rs = 0;
  reverse(V);
  for (int n : V) {
    int sz = seg.prod(t[n]).s;
    if (sz != inf<int>) chmax(rs, le[n] * K - (sz + le[n]));
    if (fa[n]) t[fa[n]] = seg.merge_to(t[fa[n]], t[n]);
  }
  print(rs);
}
```

== 总结

这篇博客在几项前置概念后放了大量例题, 我认为这样更利于读者理解如何利用 SAM 简单而强大的性质来解决问题, 至于 SAM 的实现, 读者可以自己随便去哪抄个板子