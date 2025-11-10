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


#let is_in_circle(p, triangle) = {
  let (p1, p2, p3) = triangle
  // if 3 of them are inf, true
  // if 2 of them are
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
  let (tmp_x, tmp_y) = points.at(0)
  let (min_x, min_y, max_x, max_y) = points.fold((tmp_x, tmp_y, tmp_x, tmp_y), (acc, x) =>
    {
      let (min_x, min_y, max_x, max_y) = acc;
      let (px, py) = x
      (
        calc.min(min_x, px),
        calc.min(min_y, py),
        calc.max(max_x, px),
        calc.max(max_y, py),
      )
    })
  let width = max_x - min_x
  let height = max_y - min_y
  let vertices = (
    (-10e7, -10e7),
    (10e7, -10e7),
    (-10e7, 10e7),
    //(min_x - 10., min_y - 10.),
    //(min_x + 2. * width, min_y - 10.),
    //(min_x - 10., min_y + 2. * height),
    //(min_x - 10., min_y - 10.),
    //(max_x - 10., min_y - 10.),
    //(max_x + 10., max_y + 10.),
    //(min_x + 10., max_y + 10.),
  )
  let faces = (
    (0, 1, 2),
    //(0, 2, 3),
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

    let polygon = ()
    for f_i in bad_f {
      let (f1, f2, f3) = faces.at(f_i)
      let e_1 = (f1, f2)
      let e_2 = (f2, f3)
      let e_3 = (f3, f1)
      let j = 0
      let add_1 = true
      let add_2 = true
      let add_3 = true
      let m = polygon.len()
      while j < m {
        let e = polygon.at(j)
        let matched = false
        if e == (f2, f1) {
          matched = true
          add_1 = false
        } else if e == (f3, f2) {
          matched = true
          add_2 = false
        } else if e == (f1, f3) {
          matched = true
          add_3 = false
        }

        if matched {
          let _ = polygon.remove(j)
          m -= 1
        } else {
          j += 1
        }
      }
      if add_1 {
        polygon.push(e_1)
      }
      if add_2 {
        polygon.push(e_2)
      }
      if add_3 {
        polygon.push(e_3)
      }
    }

    let cur_r = 0
    for f in bad_f {
      let _ = faces.remove(f - cur_r)
      cur_r += 1
    }

    for (e1, e2) in polygon {
      faces.push((n, e1, e2))
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
    let e1 = (f1, f2)
    let e2 = (f2, f3)
    let e3 = (f3, f1)

    let found_1 = edges.position(
      ((f22, f21, f)) => (f22 == f2 and f21 == f1)
    )
    if found_1 != none {
      let (_, _, f) = edges.remove(found_1)
      d_edges.push((i, f))
    } else {
      edges.push((f1, f2, i))
    }

    let found_2 = edges.position(
      ((f23, f22, f)) => (f23 == f3 and f22 == f2)
    )
    if found_2 != none {
      let (_, _, f) = edges.remove(found_2)
      d_edges.push((i, f))
    } else {
      edges.push((f2, f3, i))
    }

    let found_3 = edges.position(
      ((f21, f23, f)) => (f21 == f1 and f23 == f3)
    )
    if found_3 != none {
      let (_, _, f) = edges.remove(found_3)
      d_edges.push((i, f))
    } else {
      edges.push((f3, f1, i))
    }
  }
  d_edges
}
