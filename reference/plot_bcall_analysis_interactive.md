# Interactive B-Call Analysis Plot

Creates interactive plotly visualization. Needs the plotly package.

## Usage

``` r
plot_bcall_analysis_interactive(
  bcall_results,
  title = "B-Call Analysis: Legislative Voting",
  color_by = "auto"
)
```

## Arguments

- bcall_results:

  List, output from bcall_auto() or bcall()

- title:

  Character, plot title

- color_by:

  Character, variable to color by ("auto" for automatic detection)

## Value

plotly object

## Examples

``` r
# \donttest{
# Create sample data and run analysis
rollcall <- data.frame(
  vote1 = c(1, -1, 1, -1, 1),
  vote2 = c(1, -1, 1, -1, 1),
  vote3 = c(-1, 1, -1, 1, -1),
  row.names = paste0("Leg_", LETTERS[1:5])
)

results <- bcall_auto(rollcall, pivot = "Leg_B", verbose = FALSE)

# Create interactive plot (hover over points to see legislator names)
if (requireNamespace("plotly", quietly = TRUE)) {
  plot_bcall_analysis_interactive(results)
}

{"x":{"visdat":{"1b246e829da0":["function () ","plotlyVisDat"]},"cur_data":"1b246e829da0","attrs":{"1b246e829da0":{"x":{},"y":{},"text":{},"hovertemplate":"%{text}<extra><\/extra>","mode":"markers","marker":{"size":8},"color":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"title":"B-Call Analysis: Legislative Voting","xaxis":{"domain":[0,1],"automargin":true,"title":"d1 (Ideological Position)"},"yaxis":{"domain":[0,1],"automargin":true,"title":"d2 (Political Cohesion)"},"coloraxis":{"colorbar":{"title":"Auto_cluster"}},"hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[-0.73029674334022154,-0.73029674334022154,-0.73029674334022154],"y":[0,0,0],"text":["Legislator: Leg_A<br>d1: -0.73<br>d2: 0<br>Auto_cluster: left","Legislator: Leg_C<br>d1: -0.73<br>d2: 0<br>Auto_cluster: left","Legislator: Leg_E<br>d1: -0.73<br>d2: 0<br>Auto_cluster: left"],"hovertemplate":["%{text}<extra><\/extra>","%{text}<extra><\/extra>","%{text}<extra><\/extra>"],"mode":"markers","marker":{"color":"rgba(102,194,165,1)","size":8,"line":{"color":"rgba(102,194,165,1)"}},"type":"scatter","name":"left","textfont":{"color":"rgba(102,194,165,1)"},"error_y":{"color":"rgba(102,194,165,1)"},"error_x":{"color":"rgba(102,194,165,1)"},"line":{"color":"rgba(102,194,165,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[1.0954451150103324,1.0954451150103324],"y":[0,0],"text":["Legislator: Leg_B<br>d1: 1.095<br>d2: 0<br>Auto_cluster: right","Legislator: Leg_D<br>d1: 1.095<br>d2: 0<br>Auto_cluster: right"],"hovertemplate":["%{text}<extra><\/extra>","%{text}<extra><\/extra>"],"mode":"markers","marker":{"color":"rgba(141,160,203,1)","size":8,"line":{"color":"rgba(141,160,203,1)"}},"type":"scatter","name":"right","textfont":{"color":"rgba(141,160,203,1)"},"error_y":{"color":"rgba(141,160,203,1)"},"error_x":{"color":"rgba(141,160,203,1)"},"line":{"color":"rgba(141,160,203,1)"},"xaxis":"x","yaxis":"y","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}# }
```
