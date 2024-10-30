%raw(`require("./Prism.css")`)

type prismDimension = {
  // id: int,
  value: string,
  unit: string,
  side: string,
}

@react.component
let make = () => {
  open Value

  let (prismData, setPrismData) = React.useState(() => {
    value: "",
    unit: "",
    side: "",
  })

  let (prismDimensions: option<array<prismDimension>>, setPrismDimensions) = React.useState(_ =>
    None
  )

  React.useEffect1(() => {
    // Fetch the data from /examples and set the state when the promise resolves
    Fetch.fetchJson(`http://localhost:12346/prism`)
    |> Js.Promise.then_(prismsJson => {
      // NOTE: this uses an unsafe type cast, as safely parsing JSON in rescript is somewhat advanced.
      Js.Promise.resolve(setPrismDimensions(_ => Some(Obj.magic(prismsJson))))
    })
    // The "ignore" function is necessary because each statement is expected to return `unit` type, but Js.Promise.then return a Promise type.
    |> ignore
    None
  }, [setPrismDimensions])

  let handleSubmit = data => {
    Fetch.postJson(
      "http://localhost:12346/prism`",
      {
        headers: {
          "Content-Type": "application/json",
        },
        body: Js.Json.stringify(data),
      },
    )
    |> Fetch.then_(response => {
      if response.status === 200 {
        setResponseMessage("User created successfully!")
      } else {
        setResponseMessage("Failed to create user.")
      }
      response.json()
    })
    |> Fetch.then_(json => {
      // Handle the JSON response if needed
      Js.log(json)
      Js.Promise.resolve()
    })
    |> ignore // Ignore the result of the Promise
  }

  let handleUpdate = (data, side) => {
    // setPrismData(_ => )

    Js.Global.setTimeout(() =>
      handleSubmit({
        value: data,
        unit: data,
        side: side,
      })
    , 2000)->ignore
  }

  <div className="rectangle1">
    <div className="label top1"> <Value handleUpdate={handleUpdate} side="mt" /> </div>
    <div className="label right1"> <Value handleUpdate={handleUpdate} side="mr" /> </div>
    <div className="label bottom1"> <Value handleUpdate={handleUpdate} side="mb" /> </div>
    <div className="label left1"> <Value handleUpdate={handleUpdate} side="ml" /> </div>
    <div className="rectangle2">
      <div className="label top2"> <Value handleUpdate={handleUpdate} side="pt" /> </div>
      <div className="label right2"> <Value handleUpdate={handleUpdate} side="pr" /> </div>
      <div className="label bottom2"> <Value handleUpdate={handleUpdate} side="pb" /> </div>
      <div className="label left2"> <Value handleUpdate={handleUpdate} side="pl" /> </div>
    </div>
  </div>
}
