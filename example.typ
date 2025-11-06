#import "lib.typ": *

#let points = generate_random_points(200)
#let faces = generate_delaunay(points)
#let new_p = get_circumcenters(points, faces)
#let edges = get_dual_edges(faces)

#let size = 200pt
#box(width: size, height: size)[
  #for (e1, e2) in edges {
    let (v1x, v1y) = new_p.at(e1)
    let (v2x, v2y) = new_p.at(e2)
    place(top + left,
      polygon(
        (v1x * 100%, v1y * 100%),
        (v2x * 100%, v2y * 100%),
        //stroke: gradient.linear(relative: "parent", black, white)
      ))
  }
  /*
  #for (f1, f2, f3) in faces {
    let (v1x, v1y) = points.at(f1)
    let (v2x, v2y) = points.at(f2)
    let (v3x, v3y) = points.at(f3)
    place(top + left,
      polygon(
        (v1x * 100%, v1y * 100%),
        (v2x * 100%, v2y * 100%),
        (v3x * 100%, v3y * 100%),
        stroke: gradient.linear(relative: "parent", black, white)
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
