# B-Call Analysis with User-Provided Clustering

PRINCIPLE 2: User provides rollcall data AND clustering assignment. This
function runs B-Call analysis using the user's clustering.

## Usage

``` r
bcall(rollcall, clustering, pivot, threshold = 0.1, verbose = TRUE)
```

## Arguments

- rollcall:

  data.frame with rollcall voting data (legislators as rows, votes as
  columns) Values: 1 (Yes), -1 (No), 0 (Abstention), NA (Absent)

- clustering:

  data.frame with one column OR named vector with exactly 2 unique
  values

- pivot:

  Character, pivot legislator name

- threshold:

  Numeric, minimum participation threshold (0.0-1.0)

- verbose:

  Logical, whether to print progress messages

## Value

A list of class `bcall_result`, printed briefly, with: - results:
data.frame with d1, d2, cluster for each legislator - bcall_object:
BCall R6 object - metadata: Analysis metadata

## Examples

``` r
# Create sample rollcall data
rollcall <- data.frame(
  vote1 = c(1, -1, 1, -1, 1, -1),
  vote2 = c(1, -1, 1, -1, 1, -1),
  vote3 = c(-1, 1, -1, 1, -1, 1),
  row.names = c("Leg_A", "Leg_B", "Leg_C", "Leg_D", "Leg_E", "Leg_F")
)

# Create user-defined clustering (can use any 2 values)
clustering <- data.frame(
  cluster = c("left", "right", "left", "right", "left", "right"),
  row.names = c("Leg_A", "Leg_B", "Leg_C", "Leg_D", "Leg_E", "Leg_F")
)

# Run analysis with user clustering
results <- bcall(rollcall, clustering, pivot = "Leg_B", threshold = 0.1, verbose = FALSE)

# View results
head(results$results)
#>               d1 d2 legislator cluster
#> Leg_A -0.9128709  0      Leg_A    left
#> Leg_B  0.9128709  0      Leg_B   right
#> Leg_C -0.9128709  0      Leg_C    left
#> Leg_D  0.9128709  0      Leg_D   right
#> Leg_E -0.9128709  0      Leg_E    left
#> Leg_F  0.9128709  0      Leg_F   right

# Visualize
# \donttest{
plot_bcall_analysis(results)

if (requireNamespace("plotly", quietly = TRUE)) {
  plot_bcall_analysis_interactive(results)
}

{"x":{"visdat":{"1b241087e1c8":["function () ","plotlyVisDat"]},"cur_data":"1b241087e1c8","attrs":{"1b241087e1c8":{"x":{},"y":{},"text":{},"hovertemplate":"%{text}<extra><\/extra>","mode":"markers","marker":{"size":8},"color":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"title":"B-Call Analysis: Legislative Voting","xaxis":{"domain":[0,1],"automargin":true,"title":"d1 (Ideological Position)"},"yaxis":{"domain":[0,1],"automargin":true,"title":"d2 (Political Cohesion)"},"coloraxis":{"colorbar":{"title":"Cluster"}},"hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[-0.9128709291752769,-0.9128709291752769,-0.9128709291752769],"y":[0,0,0],"text":["Legislator: Leg_A<br>d1: -0.913<br>d2: 0<br>Cluster: left","Legislator: Leg_C<br>d1: -0.913<br>d2: 0<br>Cluster: left","Legislator: Leg_E<br>d1: -0.913<br>d2: 0<br>Cluster: left"],"hovertemplate":["%{text}<extra><\/extra>","%{text}<extra><\/extra>","%{text}<extra><\/extra>"],"mode":"markers","marker":{"color":"rgba(102,194,165,1)","size":8,"line":{"color":"rgba(102,194,165,1)"}},"type":"scatter","name":"left","textfont":{"color":"rgba(102,194,165,1)"},"error_y":{"color":"rgba(102,194,165,1)"},"error_x":{"color":"rgba(102,194,165,1)"},"line":{"color":"rgba(102,194,165,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[0.9128709291752769,0.9128709291752769,0.9128709291752769],"y":[0,0,0],"text":["Legislator: Leg_B<br>d1: 0.913<br>d2: 0<br>Cluster: right","Legislator: Leg_D<br>d1: 0.913<br>d2: 0<br>Cluster: right","Legislator: Leg_F<br>d1: 0.913<br>d2: 0<br>Cluster: right"],"hovertemplate":["%{text}<extra><\/extra>","%{text}<extra><\/extra>","%{text}<extra><\/extra>"],"mode":"markers","marker":{"color":"rgba(141,160,203,1)","size":8,"line":{"color":"rgba(141,160,203,1)"}},"type":"scatter","name":"right","textfont":{"color":"rgba(141,160,203,1)"},"error_y":{"color":"rgba(141,160,203,1)"},"error_x":{"color":"rgba(141,160,203,1)"},"line":{"color":"rgba(141,160,203,1)"},"xaxis":"x","yaxis":"y","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}# }
```
