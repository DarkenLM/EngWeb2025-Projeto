# Projeto

### Development
- Run `prepare.sh` to setup all apps. Use `prepare.sh --relink` if the symlinks get fucked.
- Run `build.sh` to build all node apps, required by the docker containers.
- Run `run.sh` to run the project.
  - Run `run.sh --no-web` to run only the `api` and `db` apps.
  - Run `run.sh --no-web --no-api` to run only the `db` app.
  - Run `run.sh --no-web --no-db` to run the `api` and `db` apps (because `api` depends on `db`).
  - Run `run.sh --no-api`, `run.sh --no-db` and `run.sh --no-api --no-db` have no effect.

Upon preparing the project, the file `.build.meta` and the directories `web/link` and `api/link` will be created. Do not
delete these, as they are required for building the project.

To develop the project, use `run.sh --no-web --no-api` to run the database, and use `(p)npm dev` on the `api` and `web` 
projects, which will allow you to automatically reload the runtime on every change.

### Notice
If you have any problems or complaints related in any way, shape or form related to docker, I will perform a magic trick
and make you disappear.
![They will never find your body.](./docs/repo/gun.jpeg)