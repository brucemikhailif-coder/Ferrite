# TORBOX API ENDPOINTS

## 👤 User Management - KNOW THESE

| Endpoint | Method | What It Does |
| --- | --- | --- |
| `/v1/api/user/me` | GET | Get user info. **USE THIS FIRST** to verify auth works. |
| `/v1/api/user/refreshtoken` | POST | Refresh your token. Session tokens only. |
| `/v1/api/user/deleteme` | DELETE | **DANGER ZONE.** Deletes the account. Confirm twice before calling. |
| `/v1/api/user/auth/device/start` | GET | Start device code auth flow |
| `/v1/api/user/auth/device/token` | POST | Complete device auth |

## 💾 Torrents - THE CORE FUNCTIONALITY

| Endpoint | Method | Purpose |
| --- | --- | --- |
| `/v1/api/torrents/mylist` | GET | **List all torrents.** Start here. |
| `/v1/api/torrents/createtorrent` | POST | Add torrent (file OR magnet). |
| `/v1/api/torrents/controltorrent` | POST | Start, stop, delete. **Requires torrent ID.** |
| `/v1/api/torrents/requestdl` | GET | **Get the actual download link.** This is what you want. |
| `/v1/api/torrents/checkcached` | GET/POST | Check if hash is cached. **DO THIS BEFORE ADDING** to avoid wait times. |
| `/v1/api/torrents/torrentinfo` | GET/POST | Get metadata from hash/magnet |

<aside>
💡

**PRO TIP:** Always call `checkcached` BEFORE `createtorrent`. Cached = instant download. Not cached = waiting for seeders.

</aside>

## 🌐 Web Downloads (Hosters)

| Endpoint | Method | Purpose |
| --- | --- | --- |
| `/v1/api/webdl/mylist` | GET | List web downloads |
| `/v1/api/webdl/createwebdownload` | POST | Add a URL to download |
| `/v1/api/webdl/requestdl` | GET | Get the download link |
| `/v1/api/webdl/checkcached` | GET/POST | Check if URL is cached |
| `/v1/api/webdl/hosters` | GET | **PUBLIC.** Lists all supported hosters. |

## 📡 RSS Feeds

| Endpoint | Method | Purpose |
| --- | --- | --- |
| `/v1/api/rss/getfeeds` | GET | List all feeds |
| `/v1/api/rss/addrss` | POST | Add new feed |
| `/v1/api/rss/controlrss` | POST | Enable/disable/delete feed |

## 🔗 Cloud Integrations

| Endpoint | Method | Destination |
| --- | --- | --- |
| `/v1/api/integration/googledrive` | POST | Google Drive |
| `/v1/api/integration/dropbox` | POST | Dropbox |
| `/v1/api/integration/onedrive` | POST | OneDrive |
| `/v1/api/integration/jobs` | GET | List active transfers |
| `/v1/api/integration/job/{job_id}` | DELETE | Cancel transfer |

Implementation Details

- Methods are grouped by namespaces (e.g. "unrestrict", "user")
- Supported HTTP verbs are GET, POST, PUT, and DELETE. If your client does not support all HTTP verbs you can override the verb with `X-HTTP-Verb` HTTP header
- Unless specified otherwise in the method's documentation, all successful API calls return HTTP code 200 with a JSON object
- Errors are returned with HTTP code 4XX or 5XX, a JSON object with properties "error" (an error message) and "error_code" (optional, an integer)
- Every string passed to and from the API needs to be UTF-8 encoded. For maximum compatibility, normalize to [Unicode Normalization Form C](https://unicode.org/reports/tr15/) (NFC) before UTF-8 encoding
- The API sends ETag headers and supports the `If-None-Match` header
- Dates are formatted according to the Javascript method `date.toJSON`
- Unless specified otherwise, all API methods require authentication
- **The API is limited to 250 requests per minute**. All refused requests will return HTTP 429 error and will count in the limit (bruteforcing will leave you blocked for undefined amount of time)

## Base URL

```
https://api.real-debrid.com/rest/1.0
```

---

## Authentication Endpoints

### GET /disable_access_token

**Disable current access token**

Disable current access token, returns 204 HTTP code.

**Return value:** None

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)

---

### GET /time

**Get server time**

Get server time, raw data returned. This request does not require authentication.

**Return value:** `Y-m-d H:i:s`

---

### GET /time/iso

**Get server time in ISO**

Get server time in ISO format, raw data returned. This request does not require authentication.

**Return value:** `Y-m-dTH:i:sO`

---

## /user

### GET /user

**Get current user info**

Returns some information on the current user.

**Return value:** User object

```json
{
    "id": int,
    "username": "string",
    "email": "string",
    "points": int,  // Fidelity points
    "locale": "string",  // User language
    "avatar": "string",  // URL
    "type": "string",  // "premium" or "free"
    "premium": int,  // seconds left as a Premium user
    "expiration": "string"  // jsonDate
}
```

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)

---

## /unrestrict

### POST /unrestrict/check

**Check a link**

Check if a file is downloadable on the concerned hoster. This request does not require authentication.

**Parameters:**

- `link` (POST, required) - The original hoster link
- `password` (POST) - Password to unlock the file access hoster side

**Return value:**

```json
{
    "host": "string",
    "link": "string",
    "filename": "string",
    "filesize": int,
    "supported": int  // 0 or 1
}
```

**Possible HTTP error codes:**

- `503` - File unavailable

---

### POST /unrestrict/link

**Unrestrict a link**

Unrestrict a hoster link and get a new unrestricted link.

**Parameters:**

- `link` (POST, required) - The original hoster link
- `password` (POST) - Password to unlock the file access hoster side
- `remote` (POST) - 0 or 1, use Remote traffic, dedicated servers and account sharing protections lifted

**Return value for a unique generated link:**

```json
{
    "id": "string",
    "filename": "string",
    "mimeType": "string",  // Mime Type of the file, guessed by the file extension
    "filesize": int,  // Filesize in bytes, 0 if unknown
    "link": "string",  // Original link
    "host": "string",  // Host main domain
    "chunks": int,  // Max Chunks allowed
    "crc": int,  // Disable / enable CRC check
    "download": "string",  // Generated link
    "streamable": int  // Is the file streamable on website
}
```

**Return value for multiple generated links (e.g. Youtube):**

```json
{
    "id": "string",
    "filename": "string",
    "filesize": int,
    "link": "string",
    "host": "string",
    "chunks": int,
    "crc": int,
    "download": "string",
    "streamable": int,
    "type": "string",  // Type of the file (in general, its quality)
    "alternative": [
        {
            "id": "string",
            "filename": "string",
            "download": "string",
            "type": "string"
        }
    ]
}
```

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)

---

### POST /unrestrict/folder

**Unrestrict a folder link**

Unrestrict a hoster folder link and get individual links, returns an empty array if no links found.

**Parameters:**

- `link` (POST, required) - The hoster folder link

**Return value:** Array of strings (URLs)

```json
[
    "string",  // URL
    "string",
    "string"
]
```

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)

---

### PUT /unrestrict/containerFile

**Decrypt container file**

Decrypt a container file (RSDF, CCF, CCF3, DLC).

**Return value:** Array of strings (URLs)

```json
[
    "string",
    "string",
    "string"
]
```

**Possible HTTP error codes:**

- `400` - Bad Request (see error message)
- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked, not premium)
- `503` - Service unavailable (see error message)

---

### POST /unrestrict/containerLink

**Decrypt container file from link**

Decrypt a container file from a link.

**Parameters:**

- `link` (POST, required) - HTTP Link of the container file

**Return value:** Array of strings (URLs)

**Possible HTTP error codes:**

- `400` - Bad Request (see error message)
- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked, not premium)
- `503` - Service unavailable (see error message)

---

## /traffic

### GET /traffic

**Traffic information for limited hosters**

Get traffic information for limited hosters (limits, current usage, extra packages).

**Return value:**

```json
{
    "host_domain": {  // Host main domain
        "left": int,  // Available bytes / links to use
        "bytes": int,  // Bytes downloaded
        "links": int,  // Links unrestricted
        "limit": int,
        "type": "string",  // "links", "gigabytes", "bytes"
        "extra": int,  // Additional traffic / links the user may have bought
        "reset": "string"  // "daily", "weekly" or "monthly"
    }
}
```

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)

---

### GET /traffic/details

**Traffic details on used hosters**

Get traffic details on each hoster used during a defined period.

**Parameters:**

- `start` (GET) - Start period (YYYY-MM-DD), default: a week ago
- `end` (GET) - End period (YYYY-MM-DD), default: today

**Warning:** The period cannot exceed 31 days.

**Return value:**

```json
{
    "YYYY-MM-DD": {
        "host": {  // By Host main domain
            "host_domain": int,  // bytes downloaded on concerned host
        },
        "bytes": int  // Total downloaded (in bytes) this day
    }
}
```

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)

---

## /streaming

### GET /streaming/transcode/{id}

**Get transcoding links for given file**

Get transcoding links for given file, {id} from /downloads or /unrestrict/link.

**Return value:**

```json
{
    "apple": {
        "full": "string"  // URL
    },
    "dash": {
        "full": "string"
    },
    "liveMP4": {
        "full": "string"
    },
    "h264WebM": {
        "full": "string"
    }
}
```

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)

---

### GET /streaming/mediaInfos/{id}

**Get media information for given file**

Get detailed media information for given file, {id} from /downloads or /unrestrict/link.

**Return value:** Detailed media metadata object

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)
- `503` - Service unavailable (problem finding metadata of the media)

---

## /downloads

### GET /downloads

**Get user downloads list**

Get user downloads list.

**Parameters:**

- `offset` (GET) - Starting offset (must be within 0 and X-Total-Count HTTP header)
- `page` (GET) - Pagination system
- `limit` (GET) - Entries returned per page / request (must be within 0 and 5000, default: 100)

**Warning:** You cannot use both `offset` and `page` at the same time; `page` is prioritized if both are provided.

**Return value:**

```json
[
    {
        "id": "string",
        "filename": "string",
        "mimeType": "string",
        "filesize": int,
        "link": "string",
        "host": "string",
        "chunks": int,
        "download": "string",
        "generated": "string"  // jsonDate
    }
]
```

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)

---

### DELETE /downloads/delete/{id}

**Delete a link from downloads list**

Delete a link from downloads list, returns 204 HTTP code.

**Return value:** None

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)
- `404` - Unknown Resource

---

## /torrents

### GET /torrents

**Get user torrents list**

Get user torrents list.

**Parameters:**

- `offset` (GET) - Starting offset (must be within 0 and X-Total-Count HTTP header)
- `page` (GET) - Pagination system
- `limit` (GET) - Entries returned per page / request (must be within 0 and 5000, default: 100)
- `filter` (GET) - "active", list active torrents only

**Warning:** You cannot use both `offset` and `page` at the same time; `page` is prioritized.

**Return value:**

```json
[
    {
        "id": "string",
        "filename": "string",
        "hash": "string",  // SHA1 Hash of the torrent
        "bytes": int,  // Size of selected files only
        "host": "string",
        "split": int,
        "progress": int,  // 0 to 100
        "status": "string",  // magnet_error, magnet_conversion, waiting_files_selection, queued, downloading, downloaded, error, virus, compressing, uploading, dead
        "added": "string",  // jsonDate
        "links": ["string"],
        "ended": "string",  // Only present when finished
        "speed": int,  // Only present in "downloading", "compressing", "uploading" status
        "seeders": int  // Only present in "downloading", "magnet_conversion" status
    }
]
```

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)

---

### GET /torrents/info/{id}

**Get info on torrent**

Get all information on the asked torrent.

**Return value:**

```json
{
    "id": "string",
    "filename": "string",
    "original_filename": "string",
    "hash": "string",
    "bytes": int,
    "original_bytes": int,
    "host": "string",
    "split": int,
    "progress": int,
    "status": "string",
    "added": "string",
    "files": [
        {
            "id": int,
            "path": "string",
            "bytes": int,
            "selected": int  // 0 or 1
        }
    ],
    "links": ["string"],
    "ended": "string",
    "speed": int,
    "seeders": int
}
```

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)

---

### GET /torrents/activeCount

**Get currently active torrents number**

Get currently active torrents number and the current maximum limit.

**Return value:**

```json
{
    "nb": int,  // Number of currently active torrents
    "limit": int  // Maximum number of active torrents you can have
}
```

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)

---

### GET /torrents/availableHosts

**Get available hosts**

Get available hosts to upload the torrent to.

**Return value:**

```json
[
    {
        "host": "string",
        "max_file_size": int
    }
]
```

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)

---

### PUT /torrents/addTorrent

**Add torrent file**

Add a torrent file to download, returns 201 HTTP code.

**Parameters:**

- `host` (GET) - Hoster domain (retrieved from /torrents/availableHosts)

**Return value:**

```json
{
    "id": "string",
    "uri": "string"  // URL of the created resource
}
```

**Possible HTTP error codes:**

- `400` - Bad Request (see error message)
- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked, not premium)
- `503` - Service unavailable (see error message)

---

### POST /torrents/addMagnet

**Add magnet link**

Add a magnet link to download, returns 201 HTTP code.

**Parameters:**

- `magnet` (POST, required) - Magnet link
- `host` (POST) - Hoster domain (retrieved from /torrents/availableHosts)

**Return value:**

```json
{
    "id": "string",
    "uri": "string"
}
```

**Possible HTTP error codes:**

- `400` - Bad Request (see error message)
- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked, not premium)
- `503` - Service unavailable (see error message)

---

### POST /torrents/selectFiles/{id}

**Select files of a torrent**

Select files of a torrent to start it, returns 204 HTTP code.

**Parameters:**

- `files` (POST, required) - Selected files IDs (comma separated) or "all"

**Warning:** To get file IDs, use /torrents/info/{id}

**Return value:** None

**Possible HTTP error codes:**

- `202` - Action already done
- `400` - Bad Request (see error message)
- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked, not premium)
- `404` - Wrong parameter (invalid file id(s)) / Unknown resource (invalid id)

---

### DELETE /torrents/delete/{id}

**Delete a torrent from torrents list**

Delete a torrent from torrents list, returns 204 HTTP code.

**Return value:** None

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)
- `404` - Unknown Resource

---

## /hosts

### GET /hosts

**Get supported hosts**

Get supported hosts. This request does not require authentication.

**Return value:**

```json
{
    "host_domain": {
        "id": "string",
        "name": "string",
        "image": "string"  // URL
    }
}
```

---

### GET /hosts/status

**Get status of hosters**

Get status of supported hosters and their status on competitors.

**Return value:**

```json
{
    "host_domain": {
        "id": "string",
        "name": "string",
        "image": "string",
        "supported": int,  // 0 or 1
        "status": "string",  // "up" / "down" / "unsupported"
        "check_time": "string",
        "competitors_status": {
            "competitor_domain": {
                "status": "string",
                "check_time": "string"
            }
        }
    }
}
```

---

### GET /hosts/regex

**Get all supported regex**

Get all supported links Regex, useful to find supported links inside a document. This request does not require authentication.

**Return value:** Array of regex strings

```json
[
    "string",  // RegExp
    "string"
]
```

---

### GET /hosts/regexFolder

**Get all supported regex for folder links**

Get all supported folder Regex, useful to find supported links inside a document. This request does not require authentication.

**Return value:** Array of regex strings

---

### GET /hosts/domains

**Get all supported domains**

Get all hoster domains supported on the service. This request does not require authentication.

**Return value:** Array of domain strings

```json
[
    "string",
    "string"
]
```

---

## /settings

### GET /settings

**Get current user settings**

Get current user settings with possible values to update.

**Return value:**

```json
{
    "download_port": int,
    "locale": "string",
    "streaming_language_preference": "string",
    "streaming_quality": "string",
    "mobile_streaming_quality": "string",
    "streaming_cast_audio_preference": "string"
}
```

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)

---

### POST /settings/update

**Update a user setting**

Update a user setting, returns 204 HTTP code.

**Parameters:**

- `setting_name` (POST, required) - "download_port", "locale", "streaming_language_preference", "streaming_quality", "mobile_streaming_quality", "streaming_cast_audio_preference"
- `setting_value` (POST, required) - Possible values are available in /settings

**Return value:** None

**Possible HTTP error codes:**

- `400` - Bad request (bad setting value or setting name)
- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)

---

### POST /settings/convertPoints

**Convert fidelity points**

Convert fidelity points, returns 204 HTTP code.

**Return value:** None

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)
- `503` - Service unavailable (not enough points)

---

### POST /settings/changePassword

**Send verification email to change the password**

Send the verification email to change the password, returns 204 HTTP code.

**Return value:** None

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)

---

### PUT /settings/avatarFile

**Upload avatar image**

Upload a new user avatar image, returns 204 HTTP code.

**Return value:** None

**Possible HTTP error codes:**

- `400` - Bad Request (see error message)
- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)

---

### DELETE /settings/avatarDelete

**Reset user avatar**

Reset user avatar image to default, returns 204 HTTP code.

**Return value:** None

**Possible HTTP error codes:**

- `401` - Bad token (expired, invalid)
- `403` - Permission denied (account locked)

## 📦 TorBox API Documentation

This document outlines the **TorBox API**, version 1.0.0, which is accessible at `https://api.torbox.app`.

---

## 👤 User Management Endpoints

These endpoints handle user account functionality, authentication, and settings.

| **Method** | **Path** | **Summary** | **Description** | **Security** |
| --- | --- | --- | --- | --- |
| **POST** | `/v1/api/user/refreshtoken` | **Refresh Token** | Gives the user a new API token. Requires the user's session token from the website. | $\text{OAuth2}$ |
| **GET** | `/v1/api/user/getconfirmation` | **Get Confirmation Code** | Sends a confirmation code to the user's email for account verification. | $\text{OAuth2}$ |
| **GET** | `/v1/api/user/me` | **Get User** | Returns the user's information, and optional settings. Requires API key. | $\text{OAuth2}$ |
| **POST** | `/v1/api/user/addreferral` | **Add Referral** | Adds a referral to the user's account. Does not replace an existing one. | $\text{OAuth2}$ |
| **GET** | `/v1/api/user/auth/device/start` | **Start Device Code Authorization** | Initiates the device code authorisation process. | $\text{None}$ |
| **POST** | `/v1/api/user/auth/device/token` | **Get Token From Device Code** | Returns the user's token once the device code is authorised. | $\text{None}$ |
| **DELETE** | `/v1/api/user/deleteme` | **Delete User Account** | Deletes the user's account. Requires a session token and confirmation code. | $\text{OAuth2}$ |
| **GET** | `/v1/api/user/referraldata` | **Get Referral Data** | Returns the user's referral data. | $\text{OAuth2}$ |
| **GET** | `/v1/api/user/subscriptions` | **Get Subscriptions** | Returns the user's subscription details. | $\text{OAuth2}$ |
| **GET** | `/v1/api/user/transactions` | **Get Transactions** | Returns the user's transaction history. | $\text{OAuth2}$ |
| **GET** | `/v1/api/user/transaction/pdf` | **Get Transaction Pdf** | Returns a specific transaction as a PDF. | $\text{OAuth2}$ |
| **PUT** | `/v1/api/user/settings/addsearchengines` | **Add Search Engine** | Adds a search engine to the user's account settings. | $\text{OAuth2}$ |
| **GET** | `/v1/api/user/settings/searchengines` | **Get Search Engines** | Returns the user's configured search engines. | $\text{OAuth2}$ |
| **POST** | `/v1/api/user/settings/modifysearchengines` | **Edit Search Engine** | Edits an existing search engine on the account. | $\text{OAuth2}$ |
| **POST** | `/v1/api/user/settings/controlsearchengines` | **Control Search Engine** | Allows control operations (e.g., delete, enable, disable, check) on a search engine. | $\text{OAuth2}$ |

---

## 💾 Torrent Endpoints

Endpoints for managing and interacting with torrent downloads.

| **Method** | **Path** | **Summary** | **Description** | **Security** |
| --- | --- | --- | --- | --- |
| **POST** | `/v1/api/torrents/createtorrent` | **Create Torrent** | Creates a torrent from a file or magnet link. Requires API key. | $\text{OAuth2}$ |
| **POST** | `/v1/api/torrents/asynccreatetorrent` | **Async Create Torrent** | An asynchronous version of torrent creation. Returns immediately. | $\text{OAuth2}$ |
| **POST** | `/v1/api/torrents/controltorrent` | **Control Torrent** | Controls a torrent (e.g., start, stop, delete). Requires API key. | $\text{OAuth2}$ |
| **GET** | `/v1/api/torrents/getqueued` | **Get Queued Torrents** | Gets a list of currently queued torrents. | $\text{OAuth2}$ |
| **POST** | `/v1/api/torrents/controlqueued` | **Control Queued** | Controls a queued torrent. | $\text{OAuth2}$ |
| **GET** | `/v1/api/torrents/requestdl` | **Request Download** | Requests a download link for a torrent file. | $\text{None}$ |
| **GET** | `/v1/api/torrents/mylist` | **Get My Torrent List** | Retrieves the user's list of torrents. | $\text{OAuth2}$ |
| **GET/POST** | `/v1/api/torrents/checkcached` | **Check Cached Torrent** | Checks if torrents (by hash) are cached on the server. | $\text{OAuth2}$ |
| **GET** | `/v1/api/torrents/exportdata` | **Export Torrent Data** | Exports specific data for a torrent. | $\text{OAuth2}$ |
| **POST** | `/v1/api/torrents/magnettofile` | **Magnet To File** | Converts a magnet link into a torrent file. | $\text{None}$ |
| **GET/POST** | `/v1/api/torrents/torrentinfo` | **Get Torrent Info** | Retrieves metadata for a torrent via hash, magnet, or file. | $\text{None}$ |

---

## 🌐 Web Download Endpoints

Endpoints for managing downloads from web links.

| **Method** | **Path** | **Summary** | **Description** | **Security** |
| --- | --- | --- | --- | --- |
| **POST** | `/v1/api/webdl/createwebdownload` | **Create Web Download** | Creates a web download from a link. Requires API key. | $\text{OAuth2}$ |
| **POST** | `/v1/api/webdl/asynccreatewebdownload` | **Async Create Web Download** | Asynchronously creates a web download. | $\text{OAuth2}$ |
| **POST** | `/v1/api/webdl/controlwebdownload` | **Control Web Download** | Controls a web download. Requires API key. | $\text{OAuth2}$ |
| **GET** | `/v1/api/webdl/requestdl` | **Request Web Download** | Requests a download link for a web download item. | $\text{None}$ |
| **GET** | `/v1/api/webdl/mylist` | **Get My Webdownloads List** | Retrieves the user's list of web downloads. | $\text{OAuth2}$ |
| **GET/POST** | `/v1/api/webdl/checkcached` | **Check Cached Webdownload** | Checks if web downloads (by hash) are cached. | $\text{OAuth2}$ |
| **GET** | `/v1/api/webdl/hosters` | **Get Hosters List** | Returns a list of supported hosters for web downloads. | $\text{None}$ |

---

## 🖧 Usenet Download Endpoints

Endpoints for managing Usenet downloads via links or NZB files.

| **Method** | **Path** | **Summary** | **Description** | **Security** |
| --- | --- | --- | --- | --- |
| **POST** | `/v1/api/usenet/createusenetdownload` | **Create Usenet Download** | Creates a Usenet download from a link or NZB file. | $\text{OAuth2}$ |
| **POST** | `/v1/api/usenet/asynccreateusenetdownload** | **Async Create Usenet Download** | Asynchronously creates a Usenet download. | $\text{OAuth2}$ |
| **POST** | `/v1/api/usenet/controlusenetdownload` | **Control Usenet Download** | Controls a Usenet download. | $\text{OAuth2}$ |
| **GET** | `/v1/api/usenet/requestdl` | **Request Usenet Download** | Requests a download link for a Usenet download item. | $\text{None}$ |
| **GET** | `/v1/api/usenet/mylist` | **Get My Usenetdownloads List** | Retrieves the user's list of Usenet downloads. | $\text{OAuth2}$ |
| **GET/POST** | `/v1/api/usenet/checkcached` | **Check Cached Usenetdownload** | Checks if Usenet downloads (by hash) are cached. | $\text{OAuth2}$ |

---

## 📡 RSS Feed Endpoints

Endpoints for managing automated RSS feed downloads.

| **Method** | **Path** | **Summary** | **Description** | **Security** |
| --- | --- | --- | --- | --- |
| **POST** | `/v1/api/rss/addrss` | **Add Rss Feed** | Adds a new RSS feed for automated downloads. | $\text{OAuth2}$ |
| **POST** | `/v1/api/rss/controlrss` | **Control Rss Feed** | Controls an RSS feed (e.g., enable, disable, delete). | $\text{OAuth2}$ |
| **POST** | `/v1/api/rss/modifyrss` | **Modify Rss Feed** | Modifies settings for an existing RSS feed. | $\text{OAuth2}$ |
| **GET** | `/v1/api/rss/getfeeds` | **Get Rss Feeds** | Gets all RSS feeds for the user. | $\text{OAuth2}$ |
| **GET** | `/v1/api/rss/getfeeditems` | **Get Rss Feed Items** | Gets items from a specific RSS feed. | $\text{OAuth2}$ |

---

## 🎬 Stream Endpoints

Endpoints for creating and retrieving media streams.

| **Method** | **Path** | **Summary** | **Description** | **Security** |
| --- | --- | --- | --- | --- |
| **GET** | `/v1/api/stream/createstream` | **Create Stream** | Creates a stream from a TorBox item (torrent, webdl, etc.). | $\text{OAuth2}$ |
| **GET** | `/v1/api/stream/getstreamdata` | **Get Stream Data** | Gets stream data using file and presigned tokens. | $\text{None}$ |

---

## 🔗 Integration Endpoints

Endpoints for third-party service integration, including cloud storage and OAuth.

| **Method** | **Path** | **Summary** | **Description** | **Security** |
| --- | --- | --- | --- | --- |
| **GET** | `/v1/api/integration/oauth/{provider}` | **Oauth Redirect** | Redirects to the OAuth provider for authentication. | $\text{None}$ |
| **GET/POST** | `/v1/api/integration/oauth/{provider}/callback` | **Oauth Callback** | Callback URL for OAuth provider after authentication. | $\text{None}$ |
| **GET** | `/v1/api/integration/oauth/{provider}/success` | **Oauth Success** | Provides token after successful OAuth authentication. | $\text{None}$ |
| **POST** | `/v1/api/integration/googledrive` | **Add To Google Drive** | Uploads a file/zip to Google Drive. Requires API key and OAuth token. | $\text{OAuth2}$ |
| **POST** | `/v1/api/integration/dropbox` | **Add To Dropbox** | Uploads a file/zip to Dropbox. Requires API key and OAuth token. | $\text{OAuth2}$ |
| **POST** | `/v1/api/integration/onedrive` | **Add To Onedrive** | Uploads a file/zip to Onedrive. Requires API key and OAuth token. | $\text{OAuth2}$ |
| **POST** | `/v1/api/integration/gofile` | **Add To Gofile** | Uploads a file/zip to Gofile. Requires API key. | $\text{OAuth2}$ |
| **POST** | `/v1/api/integration/1fichier** | **Add To 1Fichier** | Uploads a file/zip to 1Fichier. Requires API key. | $\text{OAuth2}$ |
| **POST** | `/v1/api/integration/pixeldrain` | **Add To Pixeldrain** | Uploads a file/zip to Pixeldrain. | $\text{OAuth2}$ |
| **DELETE** | `/v1/api/integration/job/{job_id}` | **Cancel Job** | Cancels a transfer job to a cloud service. | $\text{OAuth2}$ |
| **GET** | `/v1/api/integration/jobs` | **Get All Jobs** | Gets all active cloud transfers. | $\text{OAuth2}$ |
| **GET** | `/v1/api/integration/jobs/{hash}` | **Get Job By Hash** | Gets active transfers associated with a specific hash. | $\text{OAuth2}$ |

---

## 🧑‍💻 Vendor Management Endpoints

Endpoints for managing vendor accounts and associated users.

| **Method** | **Path** | **Summary** | **Description** | **Security** |
| --- | --- | --- | --- | --- |
| **POST** | `/v1/api/vendors/register` | **Register Vendor** | Registers a vendor account under the user's TorBox account. | $\text{OAuth2}$ |
| **GET** | `/v1/api/vendors/account` | **Get Vendor Account** | Retrieves the vendor account details for the user. | $\text{OAuth2}$ |
| **PUT** | `/v1/api/vendors/updateaccount` | **Update Vendor Account** | Updates the vendor account details. | $\text{OAuth2}$ |
| **GET** | `/v1/api/vendors/getaccounts` | **Get Vendor Accounts** | Retrieves all user accounts owned by the vendor. | $\text{OAuth2}$ |
| **GET** | `/v1/api/vendors/getaccount` | **Get User Vendor Account** | Retrieves a specific user account owned by the vendor. | $\text{OAuth2}$ |
| **POST** | `/v1/api/vendors/registeruser` | **Register New User** | Registers a new user account under the vendor. | $\text{OAuth2}$ |
| **DELETE** | `/v1/api/vendors/removeuser` | **Delete User** | Removes a user from the vendor's management (does not delete the user's TorBox account). | $\text{OAuth2}$ |
| **PATCH** | `/v1/api/vendors/refresh` | **Refresh Vendor Users** | Refreshes the plan and status for all users under the vendor. | $\text{OAuth2}$ |

---

## ⏱️ Queued Downloads Endpoints

Endpoints for general management of queued downloads (torrents, web, usenet).

| **Method** | **Path** | **Summary** | **Description** | **Security** |
| --- | --- | --- | --- | --- |
| **GET** | `/v1/api/queued/getqueued` | **Get Queued Downlodas** | Gets a list of all queued downloads for the user. | $\text{OAuth2}$ |
| **POST** | `/v1/api/queued/controlqueued` | **Control Queued** | Controls a queued download (e.g., delete, move). | $\text{OAuth2}$ |

---

## 📊 General API Endpoints

Endpoints for checking API status, fetching statistics, and notifications.

| **Method** | **Path** | **Summary** | **Description** | **Security** |
| --- | --- | --- | --- | --- |
| **GET** | `/` | **Status** | Returns the operational status of the API. | $\text{None}$ |
| **GET** | `/v1/api/stats` | **Get Stats** | Gets all general TorBox statistics. | $\text{None}$ |
| **GET** | `/v1/api/stats/30days` | **Get 30 Day Stats** | Gets TorBox statistics for the last 30 days. | $\text{None}$ |
| **GET** | `/v1/api/notifications/rss` | **Get Rss Notifications** | Returns an RSS feed of all user notifications. | $\text{None}$ |
| **GET** | `/v1/api/notifications/mynotifications` | **Get Notifications** | Returns all notifications for a user. | $\text{OAuth2}$ |
| **POST** | `/v1/api/notifications/clear` | **Clear All Notifications** | Clears all notifications for a user. | $\text{OAuth2}$ |
| **POST** | `/v1/api/notifications/clear/{id}` | **Clear Notification** | Clears a single notification by ID. | $\text{OAuth2}$ |
| **POST** | `/v1/api/notifications/test` | **Test Notification** | Sends a test notification to the user (rate limited). | $\text{OAuth2}$ |
| **GET** | `/v1/api/intercom/hash` | **Get Intercom Hash** | Returns a hashed ID and email for Intercom integration. | $\text{None}$ |
| **GET** | `/v1/api/changelogs/rss` | **Get Rss Changelog** | Returns an RSS feed for the most recent 100 changelogs. | $\text{None}$ |
| **GET** | `/v1/api/changelogs/json` | **Get Json Changelog** | Returns a JSON object for the most recent 100 changelogs. | $\text{None}$ |
| **GET** | `/v1/api/speedtest` | **Get Speedtest Files** | Gets the routes and files for a speed test based on user options. | $\text{None}$ |

---


---

# 🔴 REAL-DEBRID API ENDPOINTS

## 🔓 Unrestrict - THIS IS THE MAIN FEATURE

| Endpoint | Method | Auth | What It Does |
| --- | --- | --- | --- |
| `/unrestrict/check` | POST | ❌ | Check if link works **BEFORE** unrestricting |
| `/unrestrict/link` | POST | ✅ | **THE MAIN ONE.** Unrestrict a hoster link. |
| `/unrestrict/folder` | POST | ✅ | Unrestrict entire folder |
| `/unrestrict/containerFile` | PUT | ✅ | Decrypt RSDF, CCF, DLC files |

<aside>
🎯

**WORKFLOW:** `/unrestrict/check` → `/unrestrict/link` → download

**DO NOT** skip the check step. Wasted API calls = wasted rate limit.

</aside>

## 🧲 Torrents

| Endpoint | Method | Auth | Purpose |
| --- | --- | --- | --- |
| `/torrents` | GET | ✅ | List user torrents (paginated) |
| `/torrents/info/{id}` | GET | ✅ | Full torrent details |
| `/torrents/addTorrent` | PUT | ✅ | Upload .torrent file |
| `/torrents/addMagnet` | POST | ✅ | Add magnet link |
| `/torrents/selectFiles/{id}` | POST | ✅ | **REQUIRED** after adding. Select which files to download. |
| `/torrents/delete/{id}` | DELETE | ✅ | Remove torrent |
| `/torrents/activeCount` | GET | ✅ | Check active count vs limit |
| `/torrents/availableHosts` | GET | ✅ | Which hosts can you upload to |

<aside>
🔴

**CRITICAL:** After `addTorrent` or `addMagnet`, you **MUST** call `selectFiles/{id}` or the torrent WILL NOT START. This is not optional.

</aside>

## 📥 Downloads History

| Endpoint | Method | Auth | Purpose |
| --- | --- | --- | --- |
| `/downloads` | GET | ✅ | Get download history (paginated) |
| `/downloads/delete/{id}` | DELETE | ✅ | Remove from history |

## 🎬 Streaming

| Endpoint | Method | Auth | Purpose |
| --- | --- | --- | --- |
| `/streaming/transcode/{id}` | GET | ✅ | Get transcoded stream URLs (Apple, DASH, MP4, WebM) |
| `/streaming/mediaInfos/{id}` | GET | ✅ | Get media metadata |

## 🌐 Hosts (PUBLIC - No Auth)

| Endpoint | Method | Purpose |
| --- | --- | --- |
| `/hosts` | GET | All supported hosters |
| `/hosts/status` | GET | Hoster status + competitor comparison |
| `/hosts/regex` | GET | Regex patterns for link detection |
| `/hosts/domains` | GET | All supported domains |

## ⚙️ Settings

| Endpoint | Method | Auth | Purpose |
| --- | --- | --- | --- |
| `/settings` | GET | ✅ | Get user settings |
| `/settings/update` | POST | ✅ | Change a setting |
| `/settings/convertPoints` | POST | ✅ | Convert fidelity points to premium |

## 👤 User Info

| Endpoint | Method | Auth | Purpose |
| --- | --- | --- | --- |
| `/user` | GET | ✅ | Get account info (email, points, premium status) |
| `/time` | GET | ❌ | Server time |
| `/time/iso` | GET | ❌ | Server time (ISO format) |
| `/disable_access_token` | GET | ✅ | Revoke current token |

---

## 🛑 ERROR HANDLING - DON'T IGNORE THESE

| Code | Meaning | What To Do |
| --- | --- | --- |
| `401` | Bad/expired token | Re-authenticate. NOW. |
| `403` | Account locked/banned | User problem. Can't fix via API. |
| `404` | Resource not found | Wrong ID or endpoint. Check your work. |
| `429` | Rate limited | STOP. Wait 60 seconds. Try again. |
| `503` | Service unavailable | Their problem. Retry later. |

---

## ✅ BEFORE YOU WRITE ANY CODE

1. **Verify authentication** - Call `/user` (RD) or `/v1/api/user/me` (TB) first
2. **Check rate limits** - 250/min. Build in delays.
3. **Use check endpoints** - `checkcached`, `/unrestrict/check` save wasted calls
4. **Handle pagination** - Both APIs paginate results. Don't assume all data comes in one call.
5. **Select files on RD** - Torrents don't start without `selectFiles/{id}`

---

# Real-Debrid REST API v1.0

Complete API reference for integrating Real-Debrid services into your applications.

---

## 🔗 Base URL

```
https://api.real-debrid.com/rest/1.0
```

**Authentication**: All authenticated requests require an `Authorization: Bearer {your_api_token}` HTTP header.

---

## 📊 HTTP Status Codes

| Code | Reason |
| --- | --- |
| 200 | Success |
| 204 | Success (no content) |
| 400 | Bad Request (see error message) |
| 401 | Bad token (expired, invalid) |
| 403 | Permission denied (account locked, not premium) |
| 404 | Unknown Resource |
| 503 | Service unavailable (see error message) |

**Error Response Format**:

```json
{
  "error": "Human-readable error message",
  "error_code": 123
}
```

---

## 🔐 Authentication (OAuth2)

### Standard 3-Legged OAuth2

**Step 1**: Redirect user to authorization URL:

```
https://api.real-debrid.com/oauth/v2/auth?
  client_id={YOUR_CLIENT_ID}&
  redirect_uri={YOUR_REDIRECT_URI}&
  response_type=code&
  state={RANDOM_STATE}
```

**Step 2**: Exchange authorization code for token:

```bash
POST /oauth/v2/token
```

### Device Flow (For Apps/Scripts)

**Step 1**: Request device code:

```bash
POST /oauth/v2/device/code?client_id={YOUR_CLIENT_ID}
```

**Step 2**: Poll for token:

```bash
POST /oauth/v2/token
```

### Open-Source Client ID

For open-source projects: `X245A4XAIBGVM`

---

## 👤 User Endpoints

### Get User Information

```
GET /user
```

**Response**:

```json
{
  "id": 12345,
  "username": "user123",
  "email": "[user@example.com](mailto:user@example.com)",
  "points": 1000,
  "locale": "en",
  "avatar": "https://...",
  "type": "premium",
  "premium": 2592000,
  "expiration": "2025-12-20T00:00:00.000Z"
}
```

---

## 🔓 Unrestrict Endpoints

### Check if File is Downloadable (No Auth Required)

```
POST /unrestrict/check
```

**Parameters**:

- `link`* (string): Original hoster link
- `password` (string): Optional password

**Error**: 503 if file unavailable

### Unrestrict Hoster Link

```
POST /unrestrict/link
```

**Parameters**:

- `link`* (string): Original hoster link
- `password` (string): Optional password
- `remote` (int): 0 or 1 (use remote traffic)

**Response (Single File)**:

```json
{
  "id": "abc123",
  "filename": "[movie.mp](http://movie.mp)4",
  "mimeType": "video/mp4",
  "filesize": 1073741824,
  "link": "https://...",
  "host": "[uploaded.net](http://uploaded.net)",
  "chunks": 16,
  "crc": 1,
  "download": "https://download.link",
  "streamable": 1
}
```

**Response (Multi-file with Alternatives)**:

```json
{
  "id": "abc123",
  "filename": "[movie.mp](http://movie.mp)4",
  "filesize": 1073741824,
  "link": "https://...",
  "host": "[uploaded.net](http://uploaded.net)",
  "chunks": 16,
  "crc": 1,
  "download": "https://download.link",
  "streamable": 1,
  "type": "video",
  "alternative": [
    {
      "id": "alt1",
      "filename": "movie_[720p.mp](http://720p.mp)4",
      "download": "https://alt.link",
      "type": "720p"
    },
    {
      "id": "alt2",
      "filename": "movie_[1080p.mp](http://1080p.mp)4",
      "download": "https://alt.link2",
      "type": "1080p"
    }
  ]
}
```

### Unrestrict Hoster Folder

```
POST /unrestrict/folder
```

**Parameters**:

- `link`* (string): Hoster folder link

**Response**: Array of unrestricted links (empty if none found)

### Unrestrict Container File

```
POST /unrestrict/container
```

**Parameters**:

- `link`* (string): HTTP link of container file (.dlc, .ccf, .rsdf)

---

## 📥 Downloads

### List Downloads

```
GET /downloads?offset={int}&page={int}&limit={int}
```

**Parameters**:

- `offset` (int): Starting position
- `page` (int): Page number (prioritized over offset)
- `limit` (int): Results per page (0-5000, default 100)

**Response**:

```json
[
  {
    "id": "download123",
    "filename": "[file.zip](http://file.zip)",
    "link": "https://original.link",
    "host": "[uploaded.net](http://uploaded.net)",
    "chunks": 16,
    "download": "https://download.link",
    "generated": "2025-11-19T12:00:00.000Z"
  }
]
```

### Delete Download

```
DELETE /downloads/{id}
```

**Response**: 204 on success

---

## 🧲 Torrent Endpoints

### List Torrents

```
GET /torrents?offset={int}&page={int}&limit={int}&filter=active
```

**Parameters**:

- `offset` (int): Starting position
- `page` (int): Page number
- `limit` (int): Results per page
- `filter` (string): Filter by status (e.g., "active")

### Get Torrent Info

```
GET /torrents/info/{id}
```

**Response**:

```json
{
  "id": "torrent123",
  "filename": "Ubuntu 22.04.iso",
  "original_filename": "ubuntu-22.04-desktop-amd64.iso",
  "hash": "abc123def456",
  "bytes": 3758096384,
  "original_bytes": 3758096384,
  "host": "[real-debrid.com](http://real-debrid.com)",
  "split": 2000,
  "progress": 75,
  "status": "downloading",
  "added": "2025-11-19T12:00:00.000Z",
  "files": [
    {
      "id": 1,
      "path": "/ubuntu.iso",
      "bytes": 3758096384,
      "selected": 1
    }
  ],
  "links": ["https://link1", "https://link2"],
  "ended": "2025-11-19T13:00:00.000Z",
  "speed": 5242880,
  "seeders": 150
}
```

**Status Values**:

- `magnet_error`: Magnet link error
- `magnet_conversion`: Converting magnet to torrent
- `waiting_files_selection`: Waiting for file selection
- `queued`: Queued for download
- `downloading`: Currently downloading
- `downloaded`: Completed
- `error`: Download error
- `virus`: Virus detected
- `compressing`: Compressing files
- `uploading`: Uploading to server
- `dead`: Dead torrent

### Get Torrent Limits

```
GET /torrents/limits
```

**Response**:

```json
{
  "nb": 5,
  "limit": 100
}
```

### Get Available Hosts

```
GET /torrents/availableHosts
```

**Response**:

```json
[
  {
    "host": "[uploaded.net](http://uploaded.net)",
    "max_file_size": 5368709120
  },
  {
    "host": "[rapidgator.net](http://rapidgator.net)",
    "max_file_size": 2147483648
  }
]
```

### Add Torrent Magnet

```
POST /torrents/addMagnet
```

**Parameters**:

- `magnet`* (string): Magnet link
- `host` (string): Target host (optional)

**Response**:

```json
{
  "id": "torrent123",
  "uri": "https://api.real-debrid.com/rest/1.0/torrents/info/torrent123"
}
```

### Add Torrent File

```
PUT /torrents/addTorrent
```

**Parameters**:

- File upload in request body

### Select Torrent Files

```
POST /torrents/selectFiles/{id}
```

**Parameters**:

- `files`* (string): Comma-separated file IDs or "all"

**Example**: `files=1,2,3` or `files=all`

### Delete Torrent

```
DELETE /torrents/delete/{id}
```

**Response**: 204 on success

---

## 🎬 Media & Transcoding

### Get Transcoding Links

```
GET /transcodes/{id}
```

**Parameters**:

- `id`: Download ID from `/downloads` or `/unrestrict/link`

**Response**:

```json
[
  {
    "id": "transcode1",
    "quality": "360p",
    "download": "https://transcode.360p.link"
  },
  {
    "id": "transcode2",
    "quality": "720p",
    "download": "https://transcode.720p.link"
  },
  {
    "id": "transcode3",
    "quality": "1080p",
    "download": "https://transcode.1080p.link"
  }
]
```

<aside>
🎥

**Transcoding for Videos**: Use this endpoint to get multiple quality versions (360p, 480p, 720p, 1080p) of video files for adaptive streaming or bandwidth-limited scenarios.

</aside>

### Get Media Info

```
GET /media/{id}
```

**Response**: Media metadata including codec, resolution, duration, etc.

---

## 📡 Traffic

### Get Traffic Info

```
GET /traffic
```

**Response**:

```json
{
  "[uploaded.net](http://uploaded.net)": {
    "left": 107374182400,
    "bytes": 107374182400,
    "links": 0,
    "limit": 107374182400,
    "type": "bytes",
    "extra": 0,
    "reset": "daily"
  },
  "[rapidgator.net](http://rapidgator.net)": {
    "left": 50,
    "bytes": 0,
    "links": 50,
    "limit": 50,
    "type": "links",
    "extra": 10,
    "reset": "weekly"
  }
}
```

### Get Traffic by Period

```
GET /traffic?start=YYYY-MM-DD&end=YYYY-MM-DD
```

**Note**: Period must be ≤ 31 days

---

## 🌐 Hosts & Regex (No Auth Required)

### Get Supported Hosts

```
GET /hosts
```

**Response**: Array of supported hoster domains

### Get Hoster Status

```
GET /hosters?host={domain}
```

**Response**: Status information for specific hoster

### Get Link Regex

```
GET /regex
```

**Response**: Regular expressions for detecting supported links

### Get Folder Regex

```
GET /regex/folder
```

**Response**: Regular expressions for detecting folder links

### Get Domains

```
GET /domains
```

**Response**: List of all supported domains

---

## ⚙️ Settings

### Get Settings

```
GET /settings
```

**Response**: Current user settings

### Update Setting

```
POST /settings
```

**Parameters**:

- `setting_name`* (string): Setting to update (e.g., "download_port")
- `setting_value`* (string/int): New value

---

## 🔧 Token Management

### Disable Current Access Token

```
DELETE /token
```

**Response**: 204 on success

---

## 🕐 Server Time (No Auth Required)

### Get Server Time (Plain Format)

```
GET /time
```

**Response**: `Y-m-d H:i:s` (raw string)

### Get Server Time (ISO Format)

```
GET /time/iso
```

**Response**: `Y-m-dTH:i:sO` (raw string)

---

## 💻 Code Examples

### JavaScript/TypeScript

```tsx
// Get user info
const response = await fetch('https://api.real-debrid.com/rest/1.0/user', {
  headers: {
    'Authorization': 'Bearer YOUR_API_TOKEN'
  }
});
const user = await response.json();
console.log(user);

// Unrestrict a link
const unrestrictResponse = await fetch(
  'https://api.real-debrid.com/rest/1.0/unrestrict/link',
  {
    method: 'POST',
    headers: {
      'Authorization': 'Bearer YOUR_API_TOKEN',
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      link: 'https://example.com/file.zip'
    })
  }
);
const unrestricted = await unrestrictResponse.json();
console.log([unrestricted.download](http://unrestricted.download));

// Get transcoding links for video
const transcodesResponse = await fetch(
  `https://api.real-debrid.com/rest/1.0/transcodes/${unrestricted.id}`,
  {
    headers: {
      'Authorization': 'Bearer YOUR_API_TOKEN'
    }
  }
);
const transcodes = await transcodesResponse.json();
transcodes.forEach(t => {
  console.log(`${t.quality}: ${[t.download](http://t.download)}`);
});
```

### Python

```python
import requests

API_TOKEN = 'YOUR_API_TOKEN'
BASE_URL = 'https://api.real-debrid.com/rest/1.0'

headers = {
    'Authorization': f'Bearer {API_TOKEN}'
}

# Get user info
response = requests.get(f'{BASE_URL}/user', headers=headers)
user = response.json()
print(user)

# Unrestrict a link
data = {'link': 'https://example.com/file.zip'}
response = [requests.post](http://requests.post)(
    f'{BASE_URL}/unrestrict/link',
    headers=headers,
    data=data
)
unrestricted = response.json()
print(unrestricted['download'])

# Get transcoding links
file_id = unrestricted['id']
response = requests.get(
    f'{BASE_URL}/transcodes/{file_id}',
    headers=headers
)
transcodes = response.json()
for transcode in transcodes:
    print(f"{transcode['quality']}: {transcode['download']}")
```

### cURL

```bash
# Get user info
curl -X GET \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  "https://api.real-debrid.com/rest/1.0/user"

# Unrestrict link
curl -X POST \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d "link=https://example.com/file.zip" \
  "https://api.real-debrid.com/rest/1.0/unrestrict/link"

# Get transcodes
curl -X GET \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  "https://api.real-debrid.com/rest/1.0/transcodes/{id}"

# Add magnet
curl -X POST \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d "magnet=magnet:?xt=urn:btih:..." \
  "https://api.real-debrid.com/rest/1.0/torrents/addMagnet"

# Select all files
curl -X POST \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d "files=all" \
  "https://api.real-debrid.com/rest/1.0/torrents/selectFiles/{id}"
```

---

## 🚀 Enhanced Web App Implementation

### Updated TranscodeButton Component

```tsx
import { useState } from 'react'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Video, Loader2 } from 'lucide-react'
import { useToast } from '@/components/ui/use-toast'
import type { AlternativeLink } from '@/types/realdebrid'

interface TranscodeButtonProps {
  fileId: string
  api: any
}

export function TranscodeButton({ fileId, api }: TranscodeButtonProps) {
  const [transcodes, setTranscodes] = useState<AlternativeLink[]>([])
  const [loading, setLoading] = useState(false)
  const { toast } = useToast()

  const fetchTranscodes = async () => {
    setLoading(true)
    try {
      // First unrestrict the link to get alternatives
      const unrestricted = await api.unrestrictLink(fileId)
      
      if (unrestricted.alternative && unrestricted.alternative.length > 0) {
        setTranscodes(unrestricted.alternative)
      } else {
        // Try the transcodes endpoint
        const response = await api.client.get(`/transcodes/${[unrestricted.id](http://unrestricted.id)}`)
        if ([response.data](http://response.data) && [response.data](http://response.data).length > 0) {
          setTranscodes([response.data.map](http://response.data.map)((t: any) => ({
            id: [t.id](http://t.id),
            filename: `${unrestricted.filename} (${t.quality})`,
            download: [t.download](http://t.download),
            type: t.quality
          })))
        } else {
          toast({
            title: 'No transcodes available',
            description: 'This file does not have transcoded versions',
            variant: 'destructive'
          })
        }
      }
    } catch (error) {
      toast({
        title: 'Error',
        description: 'Failed to fetch transcoding options',
        variant: 'destructive'
      })
    } finally {
      setLoading(false)
    }
  }

  const copyLink = (link: string, quality: string) => {
    navigator.clipboard.writeText(link)
    toast({
      title: 'Link copied',
      description: `${quality} link copied to clipboard`
    })
  }

  const downloadLink = (link: string) => {
    [window.open](http://window.open)(link, '_blank')
  }

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button
          size="sm"
          variant="outline"
          onClick={fetchTranscodes}
          disabled={loading}
        >
          {loading ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            <Video className="h-4 w-4" />
          )}
        </Button>
      </DropdownMenuTrigger>
      {transcodes.length > 0 && (
        <DropdownMenuContent>
          {[transcodes.map](http://transcodes.map)((transcode) => (
            <DropdownMenuItem
              key={[transcode.id](http://transcode.id)}
              onClick={() => downloadLink([transcode.download](http://transcode.download))}
              onContextMenu={(e) => {
                e.preventDefault()
                copyLink([transcode.download](http://transcode.download), transcode.type)
              }}
            >
              {transcode.type || 'Original'}
            </DropdownMenuItem>
          ))}
        </DropdownMenuContent>
      )}
    </DropdownMenu>
  )
}
```

### Enhanced API Client with Transcoding

```tsx
// Add to RealDebridAPI class in src/lib/api/realdebrid.ts

class RealDebridAPI {
  // ... existing methods ...

  // Get transcoding options for a file
  async getTranscodes(id: string): Promise<TranscodeLink[]> {
    try {
      const response = await this.client.get(`/transcodes/${id}`)
      return [response.data](http://response.data)
    } catch (error) {
      // If transcodes endpoint fails, return empty array
      return []
    }
  }

  // Get media information
  async getMediaInfo(id: string): Promise<MediaInfo> {
    const response = await this.client.get(`/media/${id}`)
    return [response.data](http://response.data)
  }

  // Enhanced unrestrict with transcode detection
  async unrestrictLinkWithTranscodes(link: string): Promise<{
    unrestricted: UnrestrictedLink,
    transcodes: AlternativeLink[]
  }> {
    const unrestricted = await this.unrestrictLink(link)
    
    let transcodes: AlternativeLink[] = []
    
    // Check if alternatives are included in response
    if (unrestricted.alternative && unrestricted.alternative.length > 0) {
      transcodes = unrestricted.alternative
    } else if (unrestricted.streamable === 1) {
      // Try to fetch transcodes separately for streamable videos
      try {
        const transcodesData = await this.getTranscodes([unrestricted.id](http://unrestricted.id))
        transcodes = [transcodesData.map](http://transcodesData.map)(t => ({
          id: [t.id](http://t.id),
          filename: `${unrestricted.filename} (${t.quality})`,
          download: [t.download](http://t.download),
          type: t.quality
        }))
      } catch {
        // Transcodes not available
      }
    }
    
    return { unrestricted, transcodes }
  }
}

export default RealDebridAPI
```

### Updated Types

```tsx
// Add to src/types/realdebrid.ts

export interface TranscodeLink {
  id: string
  quality: string  // "360p", "480p", "720p", "1080p"
  download: string
}

export interface MediaInfo {
  id: string
  filename: string
  codec: string
  resolution: string
  duration: number
  bitrate: number
}
```

---

## 📖 Best Practices

### Rate Limiting

- Respect API rate limits
- Implement exponential backoff for retries
- Cache responses when appropriate

### Error Handling

- Always check HTTP status codes
- Parse `error` and `error_code` fields
- Handle token expiration gracefully

### Security

- Never expose API tokens in client-side code
- Use environment variables for tokens
- Implement token refresh logic
- Use HTTPS for all requests

### Transcoding Workflow

1. **Unrestrict the link** using `/unrestrict/link`
2. **Check if `streamable` field** is `1` (video file)
3. **Get transcodes** using `/transcodes/{id}` or check `alternative` array
4. **Present quality options** to user (360p, 720p, 1080p, etc.)
5. **Download or stream** selected quality

---

## 🔗 Related Pages

- [Real Debrid Web app](https://www.notion.so/Real-Debrid-Web-app-0da6d013a4374499975f0122d3827609?pvs=21)
- [real-debrid](https://www.notion.so/real-debrid-2ab383b70905808cb5c5e99d7f540988?pvs=21)
- [RealDebrid API Script](https://www.notion.so/RealDebrid-API-Script-7ff3ea4466af446eb397cb52ebb7afb1?pvs=21)

---

## 📚 Additional Resources

- [Official RealDebrid Website](https://real-debrid.com)
- [RealDebrid Support](https://real-debrid.com/support)
- [API Terms of Service](https://real-debrid.com/terms)