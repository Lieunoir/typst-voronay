// R2 sequence from https://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/
// Generates points withing $[0, 1]^2$
#let r2_sequence(i) = {
  let g = 1.32471795724474602596
  let a1 = 1.0/g
  let a2 = 1.0/(g*g)
  let x = calc.fract(0.5+a1*i)
  let y = calc.fract(0.5+a2*i)
  (x, y)
}

#let halton(i, base) = {
  let x = 1.0 / base;
  let v = 0.0;
  while (i > 0) {
    v += x * calc.rem(i, base);
    i = calc.div-euclid(i,  base);
    x /= base;
  }
  v
}

#let halton_2_3(i) = (halton(i, 2), halton(i, 3))

#let generate_random_points(n, generator: r2_sequence) = {
//#let generate_random_points(n, generator: halton_2_3) = {
  let points = ()
  let i = 0
  while i < n {
    points.push(generator(i))
    i += 1
  }
  points
}

#let det(p1, p2, p3) = {
  let (p1x, p1y) = p1
  let (p2x, p2y) = p2
  let (p3x, p3y) = p3
  let v1x = p2x - p1x
  let v1y = p2y - p1y
  let v2x = p3x - p1x
  let v2y = p3y - p1y
  v1x * v2y - v2x * v1y
}

#let is-inside(point, triangle) = {
  let p = point
  let (p1, p2, p3) = triangle
  det(p, p1, p2) > 0 and det(p, p2, p3) > 0 and det(p, p3, p1) > 0
}

/*
#let generate_triangles_from_points(points) = {
  let vertices = (
    (0., 0.),
    (1., 0.),
    (1., 1.),
    (0., 1.),
  )
  let faces = (
    (0, 1, 2),
    (0, 2, 3),
  )
  let edges = (
    (-1, -1, 1),
    (0, -1, -1),
  )
  let edges_i = (
    (-1, -1, 0),
    (2, -1, -1),
  )
  let n = 2
  for p in points {
    let i = 0
    vertices.push(p)
    while i < n {
      let (f1, f2, f3) = faces.at(i)
      let v1 = vertices.at(f1)
      let v2 = vertices.at(f2)
      let v3 = vertices.at(f3)
      if is-inside(p, (v1, v2, v3)) {
        let _ = faces.remove(i)
        let (e1, e2, e3) = edges.remove(i)
        let (e1_i, e2_i, e3_i) = edges_i.remove(i)
        faces.push((vertices.len()-1, f1, f2))
        faces.push((vertices.len()-1, f2, f3))
        faces.push((vertices.len()-1, f3, f1))
        edges.push((vertices.len()-1, f1, f2))
        edges.push((vertices.len()-1, f2, f3))
        edges.push((vertices.len()-1, f3, f1))
      }
      i += 1
    }
    n += 2
  }
  (vertices, faces)
}*/



// No input checks (degenerate or aligned vertices)
#let is_in_circle(p, triangle) = {
  let (p1, p2, p3) = triangle
  // if 3 of them are inf, true
  // if 1 of them, check on which size of th triangle the point is
  // ie if p, p2, p3 is cw or ccw
  let (ax, ay) = p1
  let (bx, by) = p2
  let (cx, cy) = p3
  let (dx, dy) = p
  let ax_ = ax - dx
  let ay_ = ay - dy
  let bx_ = bx - dx
  let by_ = by - dy
  let cx_ = cx - dx
  let cy_ = cy - dy

  (
    (ax_ * ax_ + ay_ * ay_) * (bx_ * cy_ - cx_ * by_) -
    (bx_ * bx_ + by_ * by_) * (ax_ * cy_ - cx_ * ay_) +
    (cx_ * cx_ + cy_ * cy_) * (ax_ * by_ - bx_ * ay_)
  ) > 0
}

#let generate_delaunay(points) = {
  if points.len() == 0 {
    return ()
  }
  let vertices = (
    (-10e7, -10e7),
    (10e7, -10e7),
    (-10e7, 10e7),
  )
  let faces = (
    (0, 1, 2),
  )
  let edges = (
    (-1, -1, -1),
  )
  let edges_i = (
    (-1, -1, -1),
  )

  let n_v = vertices.len()
  let n = vertices.len()
  let get_vertex(i) = {
    if i >= n_v {
      points.at(i - n_v)
    } else {
      vertices.at(i)
    }
  }

  for p in points {
    let bad_f = ()
    let j = 0

    for (f1, f2, f3) in faces {
      let v1 = get_vertex(f1)
      let v2 = get_vertex(f2)
      let v3 = get_vertex(f3)
      if is_in_circle(p, (v1, v2, v3)) {
        bad_f.push(j)
      }
      j += 1
    }
    let bad_f = bad_f.sorted()

    let polygon = ()
    for f_i in bad_f {
      let (v1, v2, v3) = faces.at(f_i)
      let (f1, f2, f3) = edges.at(f_i)
      let (f1_i, f2_i, f3_i) = edges_i.at(f_i)
      if not bad_f.contains(f1) {
        polygon.push((v1, v2, f1, f1_i))
      }
      if not bad_f.contains(f2) {
        polygon.push((v2, v3, f2, f2_i))
      }
      if not bad_f.contains(f3) {
        polygon.push((v3, v1, f3, f3_i))
      }
    }

    let n_new = polygon.len()
    let i = 0
    while i < n_new {
      let (_, e2, _, _) = polygon.at(i)
      let j = i + 2
      while j < n_new {
        let p1 = polygon.at(j)
        let (e1, _, _, _) = p1
        if e1 == e2 {
          let p2 = polygon.at(i + 1)
          polygon.at(i + 1) = p1
          polygon.at(j) = p2
          break;
        }
        j += 1
      }
      i += 1
    }

    while bad_f.len() < polygon.len() {
      faces.push((-1, -1, -1))
      edges.push((-1, -1, -1))
      edges_i.push((-1, -1, -1))
      bad_f.push(faces.len() - 1)
    }

    let prev_f = bad_f.last()
    bad_f.push(bad_f.first())

    for (i, ((e1, e2, opp_f, opp_f_i), (f, next_f))) in polygon.zip(bad_f.windows(2)).enumerate() {
      faces.at(f) = (n, e1, e2)
      edges.at(f) = (prev_f, opp_f, next_f)
      edges_i.at(f) = (2, opp_f_i, 0)
      if opp_f >= 0 {
        edges.at(opp_f).at(opp_f_i) = f
        edges_i.at(opp_f).at(opp_f_i) = 1
      }
      prev_f = f
    }
    n += 1
  }
  let good_f = ()
  for (f1, f2, f3) in faces {
    if f1 >= n_v and f2 >= n_v and f3 >= n_v {
      good_f.push((
        f1 - n_v,
        f2 - n_v,
        f3 - n_v,
      ))
    }
  }
  good_f
}

#let get_circumcenters(vertices, faces) = {
  faces.map( ((f1, f2, f3)) => {
    let (p1x, p1y) = vertices.at(f1)
    let (p2x, p2y) = vertices.at(f2)
    let (p3x, p3y) = vertices.at(f3)
    let d = 2 * (p1x * (p2y - p3y) + p2x * (p3y - p1y) + p3x * (p1y - p2y))
    let ux = ((p1x * p1x + p1y * p1y) * (p2y - p3y) + (p2x * p2x + p2y * p2y) * (p3y - p1y) + (p3x * p3x + p3y * p3y) * (p1y - p2y)) / d
    let uy = ((p1x * p1x + p1y * p1y) * (p3x - p2x) + (p2x * p2x + p2y * p2y) * (p1x - p3x) + (p3x * p3x + p3y * p3y) * (p2x - p1x)) / d
    (ux, uy)
  })
}

#let get_dual_edges(faces) = {
  let d_edges = ()
  let edges = ()
  for (i, (f1, f2, f3)) in faces.enumerate() {
    edges.push((calc.min(f1, f2), calc.max(f1, f2), i))
    edges.push((calc.min(f2, f3), calc.max(f2, f3), i))
    edges.push((calc.min(f3, f1), calc.max(f3, f1), i))
  }
  let edges = edges.sorted(key: ((e_1, e_2, _)) => (e_1, e_2))
  let i = 0
  while i+1 < edges.len() {
    let (e11, e12, f1) = edges.at(i)
    let (e21, e22, f2) = edges.at(i+1)
    if e11 == e21 and e12 == e22 {
      d_edges.push((f1, f2))
      i += 2
    } else {
      i += 1
    }
  }
  d_edges
}
