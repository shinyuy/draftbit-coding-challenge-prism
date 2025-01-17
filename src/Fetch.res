module Response = {
  type t

  @send
  external json: t => Js.Promise.t<Js.Json.t> = "json"

  @send
  external text: t => Js.Promise.t<string> = "text"

  @get
  external ok: t => bool = "ok"

  @get
  external status: t => int = "status"

  @get
  external statusText: t => string = "statusText"
}

type options = {
  headers: Js.Dict.t<string>,
  method: string,
}
type postOptions = {
  headers: Js.Dict.t<string>,
  method: string,
  body: Js.Dict.t<string>,
}

@val
external fetch: (string, options) => Js.Promise.t<Response.t> = "fetch"
external post: (string, postOptions) => Js.Promise.t<Response.t> = "fetch"

let fetchJson = (~headers=Js.Dict.empty(), url: string): Js.Promise.t<Js.Json.t> =>
  fetch(url, {headers: headers, method: "GET"}) |> Js.Promise.then_(res =>
    if !Response.ok(res) {
      res->Response.text->Js.Promise.then_(text => {
        let msg = `${res->Response.status->Js.Int.toString} ${res->Response.statusText}: ${text}`
        Js.Exn.raiseError(msg)
      }, _)
    } else {
      res->Response.json
    }
  )

let postJson = (/* ~headers=Js.Dict.empty(), */ url: string, body, headers): Js.Promise.t<
  Js.Json.t,
> =>
  post(url, {headers: headers, method: "POST", body: body}) |> Js.Promise.then_(res =>
    if !Response.ok(res) {
      res->Response.text->Js.Promise.then_(text => {
        let msg = `${res->Response.status->Js.Int.toString} ${res->Response.statusText}: ${text}`
        Js.Exn.raiseError(msg)
      }, _)
    } else {
      res->Response.json
    }
  )
