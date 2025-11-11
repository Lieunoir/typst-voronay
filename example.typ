#import "@preview/voronay:0.1.0": *

#set page(width: auto, height: auto, margin: 0.6pt)

#let width = 300pt
#let height = 75pt
#let ratio = height / width
#box(width: width, height: height, {
  // Generate points
  let points = range(100).map(halton-2-3).map(((x, y)) => (x, y * ratio))
  let points = hilbert-point-sort(points)
  // Generate Delaunay triangulation
  let faces = delaunay-triangulate(points)

  // Compute the triangulation dual (the Voronoi diagram)
  let dual-vertices = get-circumcenters(points, faces)
  let dual-edges = get-dual-edges(faces)

  // Draw the Delaunay triangles
  let grad = gradient.linear(red, yellow)
  for (i, (f1, f2, f3)) in faces.enumerate() {
    let (v1x, v1y) = points.at(f1)
    let (v2x, v2y) = points.at(f2)
    let (v3x, v3y) = points.at(f3)

    let w = ((v1x + v2x + v3x)
      + (v1y + v2y + v3y) / ratio) / 6.
    let c = grad.sample(w * 100%)
    place(top + left,
      // Offset to cover the whole box
      dx: -8%,
      dy: -8%,
      polygon(
        // The triangulation has to be dilated to cover the whole box
        (v1x * width * 120%, v1y * width * 120%),
        (v2x * width * 120%, v2y * width * 120%),
        (v3x * width * 120%, v3y * width * 120%),
        // Without stroke anti alisaing may add ugly artifacts
        stroke: c + 0.5pt,
        fill: c,
      ))
  }

  // Draw the Voronoi edges
  for (e1, e2) in dual-edges {
    let (v1x, v1y) = dual-vertices.at(e1)
    let (v2x, v2y) = dual-vertices.at(e2)
    let w = ((v1x + v2x) + 2. - (v1y + v2y) / ratio) / 4.
    place(top + left,
      dx: -8%,
      dy: -8%,
      polygon(
        (v1x * width * 120%, v1y * width * 120%),
        (v2x * width * 120%, v2y * width * 120%),
        stroke: 1pt + black.transparentize(calc.pow(calc.abs(w), 0.5) * 30% + 70%)
      ))
  }

  align(center + horizon, text(red.darken(50%), 62pt, [Voronay]))
})
