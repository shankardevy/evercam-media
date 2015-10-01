defmodule EvercamMedia.Snapshot.S3Upload do

  def put(camera_exid, timestamp, image) do
    file_path = "/#{camera_exid}/snapshots/#{timestamp}.jpg"
    date = Calendar.DateTime.now!("UTC") |> Calendar.DateTime.Format.httpdate
    host = "#{System.get_env("AWS_BUCKET")}.s3.amazonaws.com"
    url = "#{host}#{file_path}"
    content_type = "image/jpeg"
    string = "PUT\n\n#{content_type}\n#{date}\n/#{System.get_env("AWS_BUCKET")}#{file_path}"
    signature = :crypto.hmac(:sha, "#{System.get_env("AWS_SECRET_KEY")}", string) |> Base.encode64
    authorization = "AWS #{System.get_env("AWS_ACCESS_KEY")}:#{signature}"

    headers = [
      "Host": host,
      "Date": date,
      "Content-Type": content_type,
      "Authorization": authorization
    ]

    HTTPoison.put(url, image, headers)
  end
end
