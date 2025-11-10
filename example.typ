#import "lib.typ": *

#let points = generate_random_points(400)
#let points = points.map(p => (p.at(0), 3. * p.at(1)))
#let points = hilbert_point_sort(points)
#let (tot_iter, faces) = generate_delaunay(points)

#let new_p = get_circumcenters(points, faces)
#let edges = get_dual_edges(faces)

#let size = 200pt
#box(width: size, height: size, clip: false)[
  #for (f1, f2, f3) in faces {
    let c1 = blue
    let c2 = yellow
    let (v1x, v1y) = points.at(f1)
    let (v2x, v2y) = points.at(f2)
    let (v3x, v3y) = points.at(f3)
    let bx = (v1x + v2x + v3x) / 3.
    let by = (v1y + v2y + v3y) / 3.
    let w = (v1x + v1y + v2x + v2y + v3x + v3y) / 6.
    let c = color.mix((blue, w), (yellow, (1. - w)))
    place(top + left,
      dx: -12%,
      dy: -12%,
      polygon(
        ((bx - (bx - v1x) * 1.01) * 125%, (by - (by - v1y)*1.01) * 125%),
        ((bx - (bx - v2x) * 1.01) * 125%, (by - (by - v2y)*1.01) * 125%),
        ((bx - (bx - v3x) * 1.01) * 125%, (by - (by - v3y)*1.01) * 125%),
        //stroke: gradient.linear(relative: "parent", black, white)
        stroke: none,
        fill: c,
      ))
  }
  /*
  #for (e1, e2) in edges {
    let (v1x, v1y) = new_p.at(e1)
    let (v2x, v2y) = new_p.at(e2)
    place(top + left,
      dx: -12%,
      dy: -12%,
      polygon(
        (v1x * 125%, v1y * 125%),
        (v2x * 125%, v2y * 125%),
        //stroke: gradient.linear(relative: "parent", black, white)
      ))
  }*/

  /*
  #for (x, y) in points {
    place(top + left, dx: size * x, dy: size * y)[
      #circle(radius: 2pt)
    ]
  }
  */
]
